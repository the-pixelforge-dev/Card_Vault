import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/card_list_provider.dart';
import '../../application/groups/group_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../application/settings/settings_provider.dart';
import '../../core/network_detection/card_network_detector.dart';
import '../../domain/card/card_entity.dart';
import '../../domain/card/card_network.dart';
import '../../domain/card/card_type.dart';
import '../../domain/card/card_validator.dart';
import '../../domain/card/cvv_validator.dart';
import '../../domain/card/expiry_validator.dart';
import '../../domain/card/luhn_validator.dart';
import '../widgets_shared/card_visual_style.dart';
import 'expiry_input_formatter.dart';

const _presetColors = <int>[
  0xFF6C5CE7,
  0xFF0984E3,
  0xFF00B894,
  0xFFE17055,
  0xFFD63031,
  0xFFE84393,
  0xFF2D3436,
  0xFFFDCB6E,
  0xFF00CEC9,
  0xFF8E44AD,
  0xFFE67E22,
  0xFF1ABC9C,
  0xFF4834D4,
];

/// Add/edit form. When [existingCard] is null this creates a new card.
class CardFormScreen extends ConsumerStatefulWidget {
  const CardFormScreen({super.key, this.existingCard});

  final CardEntity? existingCard;

  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cardholderController;
  late final TextEditingController _numberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late final TextEditingController _issuerController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _rewardsController;
  late final TextEditingController _bestForController;
  late final TextEditingController _rewardsUrlController;
  late final TextEditingController _paymentUrlController;
  late final TextEditingController _managementUrlController;
  late final TextEditingController _customerServiceUrlController;
  late final TextEditingController _notesController;

  CardNetwork _network = CardNetwork.unknown;
  CardType _cardType = CardType.credit;
  int _colorArgb = _presetColors.first;
  bool _isCustomColor = false;
  Set<String> _selectedGroupIds = {};
  List<MapEntry<String, String>> _customFields = [];

  bool get _isEditing => widget.existingCard != null;

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;
    _cardholderController = TextEditingController(
      text: card?.cardholderName ??
          ref.read(settingsProvider).defaultCardholderName,
    );
    _numberController = TextEditingController(text: card?.cardNumber);
    _expiryController = TextEditingController(text: card?.expiryMonthYear);
    _cvvController = TextEditingController(text: card?.cvv);
    _issuerController = TextEditingController(text: card?.issuerName);
    _nicknameController = TextEditingController(text: card?.nickname);
    _rewardsController = TextEditingController(text: card?.rewardsText);
    _bestForController = TextEditingController(text: card?.bestForText);
    _rewardsUrlController = TextEditingController(text: card?.rewardsUrl);
    _paymentUrlController = TextEditingController(text: card?.paymentUrl);
    _managementUrlController = TextEditingController(
      text: card?.managementUrl,
    );
    _customerServiceUrlController = TextEditingController(
      text: card?.customerServiceUrl,
    );
    _notesController = TextEditingController(text: card?.notes);

    _network = card?.network ??
        CardNetworkDetector.detect(_numberController.text);
    _cardType = card?.cardType ?? CardType.credit;
    _colorArgb = card?.colorArgb ?? _presetColors.first;
    _isCustomColor = card != null && !_presetColors.contains(card.colorArgb);
    _selectedGroupIds = {...(card?.groupIds ?? [])};
    _customFields = (card?.customFields ?? {}).entries.toList();

    _numberController.addListener(_onNumberChanged);
  }

  void _onNumberChanged() {
    final detected = CardNetworkDetector.detect(_numberController.text);
    if (detected != _network) {
      setState(() => _network = detected);
    }
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _issuerController.dispose();
    _nicknameController.dispose();
    _rewardsController.dispose();
    _bestForController.dispose();
    _rewardsUrlController.dispose();
    _paymentUrlController.dispose();
    _managementUrlController.dispose();
    _customerServiceUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    ref.read(hapticsServiceProvider).selectionClick();
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields correctly.'),
          ),
        );
      return;
    }

    final now = DateTime.now();
    final existing = widget.existingCard;
    final card = CardEntity(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      cardholderName: _cardholderController.text.trim(),
      cardNumber: _numberController.text.replaceAll(RegExp(r'\D'), ''),
      expiryMonthYear: _expiryController.text.trim(),
      cvv: _cvvController.text.trim(),
      issuerName: _issuerController.text.trim(),
      network: _network,
      cardType: _cardType,
      nickname: _nicknameController.text.trim(),
      colorArgb: _colorArgb,
      rewardsText: _rewardsController.text.trim(),
      bestForText: _bestForController.text.trim(),
      rewardsUrl: _emptyToNull(_rewardsUrlController.text),
      paymentUrl: _emptyToNull(_paymentUrlController.text),
      managementUrl: _emptyToNull(_managementUrlController.text),
      customerServiceUrl: _emptyToNull(_customerServiceUrlController.text),
      customFields: {
        for (final e in _customFields)
          if (e.key.trim().isNotEmpty) e.key.trim(): e.value,
      },
      notes: _notesController.text.trim(),
      groupIds: _selectedGroupIds.toList(),
      sortOrder: existing?.sortOrder ?? now.millisecondsSinceEpoch,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(cardListProvider.notifier).upsert(card);
    } on CardValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    ref.read(hapticsServiceProvider).selectionClick();
    final existing = widget.existingCard;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text(
          'This permanently removes "${existing.nickname}" from Card Vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cardListProvider.notifier).remove(existing.id);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _pickCustomColor() async {
    ref.read(hapticsServiceProvider).selectionClick();
    var pickedColor = Color(_colorArgb);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (color) => pickedColor = color,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _colorArgb = pickedColor.toARGB32();
        _isCustomColor = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Card Details'),
            SegmentedButton<CardType>(
              segments: const [
                ButtonSegment(
                  value: CardType.credit,
                  label: Text('Credit Card'),
                  icon: Icon(Icons.credit_card_rounded),
                ),
                ButtonSegment(
                  value: CardType.debit,
                  label: Text('Debit Card'),
                  icon: Icon(Icons.payments_outlined),
                ),
              ],
              selected: {_cardType},
              onSelectionChanged: (selection) {
                ref.read(hapticsServiceProvider).selectionClick();
                setState(() => _cardType = selection.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardholderController,
              decoration: const InputDecoration(labelText: 'Cardholder name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: 'Card number',
                suffixText: _network == CardNetwork.unknown
                    ? null
                    : _network.displayName,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final digits = v ?? '';
                if (!LuhnValidator.isValid(digits)) {
                  return 'Enter a valid card number';
                }
                if (_network.validNumberLengths.isNotEmpty &&
                    !_network.validNumberLengths.contains(digits.length)) {
                  final lengths = _network.validNumberLengths.toList()
                    ..sort();
                  return '${_network.displayName} numbers are ${lengths.join(" or ")} digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ExpiryInputFormatter()],
                    validator: (v) => ExpiryValidator.hasValidFormat(v ?? '')
                        ? null
                        : 'MM/YY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(labelText: 'CVV'),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) =>
                        CvvValidator.isValid(v ?? '', _network)
                            ? null
                            : '${_network.cvvLength} digits',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(labelText: 'Issuer / Bank'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Card name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            _SectionLabel('Appearance'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._presetColors.map(
                  (colorArgb) => GestureDetector(
                    onTap: () {
                      ref.read(hapticsServiceProvider).selectionClick();
                      setState(() {
                        _colorArgb = colorArgb;
                        _isCustomColor = false;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorArgb),
                        shape: BoxShape.circle,
                        border: !_isCustomColor && _colorArgb == colorArgb
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickCustomColor,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isCustomColor
                          ? Color(_colorArgb)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isCustomColor
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: _isCustomColor ? 3 : 1.5,
                      ),
                    ),
                    child: _isCustomColor
                        ? null
                        : Icon(
                            Icons.colorize_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MiniPreview(colorArgb: _colorArgb),
            const SizedBox(height: 32),
            _SectionLabel('Rewards & Notes'),
            TextFormField(
              controller: _rewardsController,
              decoration: const InputDecoration(labelText: 'Rewards'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _bestForController,
              decoration: const InputDecoration(labelText: 'Best for'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _SectionLabel('Links'),
            TextFormField(
              controller: _rewardsUrlController,
              decoration: const InputDecoration(labelText: 'Rewards URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _paymentUrlController,
              decoration: const InputDecoration(labelText: 'Payment URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _managementUrlController,
              decoration: const InputDecoration(labelText: 'Management URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _customerServiceUrlController,
              decoration: const InputDecoration(
                labelText: 'Customer Service URL',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
            _SectionLabel('Custom Fields'),
            ..._customFields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: field.key,
                        decoration: const InputDecoration(labelText: 'Label'),
                        onChanged: (v) => _customFields[index] = MapEntry(
                          v,
                          _customFields[index].value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: field.value,
                        decoration: const InputDecoration(labelText: 'Value'),
                        onChanged: (v) => _customFields[index] = MapEntry(
                          _customFields[index].key,
                          v,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(hapticsServiceProvider).selectionClick();
                        setState(() => _customFields.removeAt(index));
                      },
                    ),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(hapticsServiceProvider).selectionClick();
                setState(() => _customFields.add(const MapEntry('', '')));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
            const SizedBox(height: 32),
            _SectionLabel('Groups'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups
                  .map(
                    (g) => FilterChip(
                      label: Text(g.name),
                      selected: _selectedGroupIds.contains(g.id),
                      onSelected: (selected) {
                        ref.read(hapticsServiceProvider).selectionClick();
                        setState(() {
                          if (selected) {
                            _selectedGroupIds.add(g.id);
                          } else {
                            _selectedGroupIds.remove(g.id);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Save Changes' : 'Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.colorArgb});
  final int colorArgb;

  @override
  Widget build(BuildContext context) {
    final style = CardVisualStyle(colorArgb);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
