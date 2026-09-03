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
import '../widgets_shared/full_text_editor_screen.dart';
import '../widgets_shared/info_tooltip_icon.dart';
import 'card_number_input_formatter.dart';
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
  late final TextEditingController _cardVariantController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _pinController;
  late final TextEditingController _rewardsController;
  late final TextEditingController _bestForController;
  late final TextEditingController _rewardsUrlController;
  late final TextEditingController _paymentUrlController;
  late final TextEditingController _managementUrlController;
  late final TextEditingController _customerServiceUrlController;
  late final TextEditingController _notesController;

  CardNetwork _network = CardNetwork.unknown;
  /// Once true, [_onNumberChanged] stops overwriting [_network] — some
  /// networks (notably RuPay cards co-badged onto JCB's own numbering
  /// range) can't be told apart from the digits alone, so a manual pick
  /// has to stick instead of being silently re-guessed on every keystroke.
  bool _networkManuallySet = false;
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
    _numberController = TextEditingController(
      text: card == null
          ? null
          : CardNumberInputFormatter.format(card.cardNumber),
    );
    _expiryController = TextEditingController(text: card?.expiryMonthYear);
    _cvvController = TextEditingController(text: card?.cvv);
    _issuerController = TextEditingController(text: card?.issuerName);
    _nicknameController = TextEditingController(text: card?.nickname);
    _cardVariantController = TextEditingController(text: card?.cardVariant);
    _creditLimitController = TextEditingController(
      text: card?.creditLimit == null
          ? null
          : _formatCreditLimit(card!.creditLimit!),
    );
    _pinController = TextEditingController(text: card?.pin);
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
    // Trust whatever network is already saved on an existing card — it may
    // have been a manual correction — rather than silently re-guessing it
    // the moment the number field is touched (e.g. to fix a typo).
    _networkManuallySet = card != null;
    _cardType = card?.cardType ?? CardType.credit;
    _colorArgb = card?.colorArgb ?? _presetColors.first;
    _isCustomColor = card != null && !_presetColors.contains(card.colorArgb);
    _selectedGroupIds = {...(card?.groupIds ?? [])};
    _customFields = (card?.customFields ?? {}).entries.toList();

    _numberController.addListener(_onNumberChanged);
  }

  String _formatCreditLimit(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  void _onNumberChanged() {
    if (_networkManuallySet) return;
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
    _cardVariantController.dispose();
    _creditLimitController.dispose();
    _pinController.dispose();
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
      cardVariant: _cardVariantController.text.trim(),
      creditLimit: double.tryParse(_creditLimitController.text.trim()),
      pin: _pinController.text.trim(),
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

  Future<void> _expandField(
    TextEditingController controller,
    String title,
  ) async {
    ref.read(hapticsServiceProvider).selectionClick();
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => FullTextEditorScreen(
          title: title,
          initialText: controller.text,
        ),
      ),
    );
    if (result != null) controller.text = result;
  }

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
    final currency = ref.watch(settingsProvider).currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
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
              decoration: const InputDecoration(labelText: 'Card number'),
              keyboardType: TextInputType.number,
              inputFormatters: [CardNumberInputFormatter()],
              validator: (v) {
                final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Network',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const InfoTooltipIcon(
                      message:
                          'Auto-detected from the card number. Some '
                          'networks (like RuPay cards issued on JCB\'s '
                          'range) can look identical from the number '
                          'alone — pick the right one here if it\'s wrong.',
                    ),
                  ],
                ),
                DropdownButton<CardNetwork>(
                  borderRadius: BorderRadius.circular(16),
                  value: _network,
                  items: CardNetwork.values
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text(n.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (n) {
                    if (n == null) return;
                    ref.read(hapticsServiceProvider).selectionClick();
                    setState(() {
                      _network = n;
                      _networkManuallySet = true;
                    });
                  },
                ),
              ],
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _cardVariantController,
              decoration: const InputDecoration(
                labelText: 'Card Variant',
                hintText: 'e.g. Platinum, Signature, World Elite',
                helperText: 'Optional',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditLimitController,
                    decoration: InputDecoration(
                      labelText: 'Credit Limit',
                      prefixText: '${currency.symbol} ',
                      helperText: 'Optional',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      helperText: 'Optional',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
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
            _ExpandableFormField(
              controller: _rewardsController,
              label: 'Rewards',
              onExpand: () => _expandField(_rewardsController, 'Rewards'),
            ),
            const SizedBox(height: 20),
            _ExpandableFormField(
              controller: _bestForController,
              label: 'Best for',
              onExpand: () => _expandField(_bestForController, 'Best For'),
            ),
            const SizedBox(height: 20),
            _ExpandableFormField(
              controller: _notesController,
              label: 'Notes',
              onExpand: () => _expandField(_notesController, 'Notes'),
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
            _SectionLabel(
              'Groups',
              tooltip:
                  'Create groups first in Settings → Manage Groups (e.g. '
                  'Travel, Dining), then check off as many as apply to this '
                  'card here.',
            ),
            if (groups.isEmpty)
              Text(
                'No groups yet — create some in Settings → Manage Groups.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
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
  const _SectionLabel(this.text, {this.tooltip});
  final String text;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: tooltip == null
          ? Text(text, style: style)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: style),
                const SizedBox(width: 4),
                InfoTooltipIcon(message: tooltip!),
              ],
            ),
    );
  }
}

/// A multi-line [TextFormField] with a small "expand" button pinned to its
/// bottom-right corner, opening [FullTextEditorScreen] for more room to
/// write, paste, or review a long entry.
class _ExpandableFormField extends StatelessWidget {
  const _ExpandableFormField({
    required this.controller,
    required this.label,
    required this.onExpand,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onExpand;

  static const _maxLines = 5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            alignLabelWithHint: true,
          ),
          maxLines: _maxLines,
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: IconButton(
            icon: const Icon(Icons.open_in_full, size: 18),
            tooltip: 'Expand',
            onPressed: onExpand,
          ),
        ),
      ],
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
