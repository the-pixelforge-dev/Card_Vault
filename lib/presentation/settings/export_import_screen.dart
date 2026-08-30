import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/card_list_provider.dart';
import '../../application/groups/group_provider.dart';
import '../../core/security/crypto/export_cipher.dart';
import '../../domain/card/card_entity.dart';
import '../../domain/card/card_network.dart';
import '../../domain/card/card_type.dart';
import '../../domain/group/group_entity.dart';

class ExportImportScreen extends ConsumerStatefulWidget {
  const ExportImportScreen({super.key});

  @override
  ConsumerState<ExportImportScreen> createState() =>
      _ExportImportScreenState();
}

class _ExportImportScreenState extends ConsumerState<ExportImportScreen> {
  bool _busy = false;
  String? _status;

  Map<String, Object?> _cardToJson(CardEntity c) => {
    'id': c.id,
    'cardholderName': c.cardholderName,
    'cardNumber': c.cardNumber,
    'expiryMonthYear': c.expiryMonthYear,
    'cvv': c.cvv,
    'issuerName': c.issuerName,
    'network': c.network.name,
    'cardType': c.cardType.name,
    'nickname': c.nickname,
    'colorArgb': c.colorArgb,
    'artworkImagePath': c.artworkImagePath,
    'rewardsText': c.rewardsText,
    'bestForText': c.bestForText,
    'rewardsUrl': c.rewardsUrl,
    'paymentUrl': c.paymentUrl,
    'managementUrl': c.managementUrl,
    'customerServiceUrl': c.customerServiceUrl,
    'customFields': c.customFields,
    'notes': c.notes,
    'groupIds': c.groupIds,
    'sortOrder': c.sortOrder,
    'createdAt': c.createdAt.toIso8601String(),
    'updatedAt': c.updatedAt.toIso8601String(),
  };

  CardEntity _cardFromJson(Map<String, Object?> j) => CardEntity(
    id: j['id'] as String,
    cardholderName: j['cardholderName'] as String,
    cardNumber: j['cardNumber'] as String,
    expiryMonthYear: j['expiryMonthYear'] as String,
    cvv: j['cvv'] as String,
    issuerName: j['issuerName'] as String,
    network: CardNetwork.values.byName(j['network'] as String),
    cardType: CardType.values.byName(j['cardType'] as String? ?? 'credit'),
    nickname: j['nickname'] as String,
    colorArgb: j['colorArgb'] as int,
    artworkImagePath: j['artworkImagePath'] as String?,
    rewardsText: j['rewardsText'] as String? ?? '',
    bestForText: j['bestForText'] as String? ?? '',
    rewardsUrl: j['rewardsUrl'] as String?,
    paymentUrl: j['paymentUrl'] as String?,
    managementUrl: j['managementUrl'] as String?,
    customerServiceUrl: j['customerServiceUrl'] as String?,
    customFields: Map<String, String>.from(
      j['customFields'] as Map? ?? const {},
    ),
    notes: j['notes'] as String? ?? '',
    groupIds: List<String>.from(j['groupIds'] as List? ?? const []),
    sortOrder: j['sortOrder'] as int,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  Map<String, Object?> _groupToJson(GroupEntity g) => {
    'id': g.id,
    'name': g.name,
    'colorArgb': g.colorArgb,
    'sortOrder': g.sortOrder,
  };

  GroupEntity _groupFromJson(Map<String, Object?> j) => GroupEntity(
    id: j['id'] as String,
    name: j['name'] as String,
    colorArgb: j['colorArgb'] as int?,
    sortOrder: j['sortOrder'] as int,
  );

  Future<void> _export() async {
    final passphrase = await _promptPassphrase(confirm: true);
    if (passphrase == null) return;

    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final cards = ref.read(cardListProvider);
      final groups = ref.read(groupListProvider);
      final payload = jsonEncode({
        'cards': cards.map(_cardToJson).toList(),
        'groups': groups.map(_groupToJson).toList(),
      });

      const cipher = ExportCipher();
      final blob = await cipher.encrypt(
        plainText: utf8.encode(payload),
        passphrase: passphrase,
      );

      final fileName =
          'card_vault_backup_${DateTime.now().millisecondsSinceEpoch}.cardvault';
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(blob.encodePretty())),
      );

      setState(() => _status = 'Export complete.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['cardvault'],
      dialogTitle: 'Choose a Card Vault backup',
    );
    if (picked == null || picked.path == null) return;
    if (!mounted) return;

    final confirmedOverwrite = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace all data?'),
        content: const Text(
          'Importing replaces every card and group currently saved on this '
          'device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (confirmedOverwrite != true) return;

    final passphrase = await _promptPassphrase(confirm: false);
    if (passphrase == null) return;

    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final raw = await File(picked.path!).readAsString();
      final blob = EncryptedExportBlob.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );

      const cipher = ExportCipher();
      final plainText = await cipher.decrypt(
        blob: blob,
        passphrase: passphrase,
      );
      final decoded = jsonDecode(utf8.decode(plainText)) as Map<String, Object?>;

      final cards = (decoded['cards'] as List)
          .map((e) => _cardFromJson(e as Map<String, Object?>))
          .toList();
      final groups = (decoded['groups'] as List)
          .map((e) => _groupFromJson(e as Map<String, Object?>))
          .toList();

      for (final group in groups) {
        await ref.read(groupListProvider.notifier).upsert(group);
      }
      for (final card in cards) {
        await ref.read(cardListProvider.notifier).upsert(card);
      }

      setState(() => _status = 'Imported ${cards.length} card(s).');
    } on ExportDecryptionException catch (e) {
      setState(() => _status = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _promptPassphrase({required bool confirm}) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();

    String? error;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(confirm ? 'Set export passphrase' : 'Enter passphrase'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                ),
                if (confirm) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final value = controller.text;
                  if (value.length < 8) {
                    setDialogState(
                      () => error = 'Use at least 8 characters.',
                    );
                    return;
                  }
                  if (confirm && value != confirmController.text) {
                    setDialogState(() => error = 'Passphrases don\'t match.');
                    return;
                  }
                  Navigator.of(dialogContext).pop(value);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Export / Import')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Export creates an AES-256-GCM encrypted .cardvault file '
            'protected by a passphrase you choose. It never leaves this '
            'device unless you move it yourself, and your Gemini API key '
            '(if set) is never included.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Export encrypted backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Import from backup'),
          ),
          if (_busy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_status != null) ...[
            const SizedBox(height: 20),
            Text(_status!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
