import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/groups/group_provider.dart';
import '../../application/settings/haptics_provider.dart';
import '../../domain/group/group_entity.dart';
import '../widgets_shared/blurred_dialog.dart';

const _groupColors = <int>[
  0xFF6C5CE7,
  0xFF0984E3,
  0xFF00B894,
  0xFFE17055,
  0xFFD63031,
  0xFFE84393,
  0xFF00CEC9,
  0xFFF0932B,
  0xFF8E44AD,
  0xFF4834D4,
];

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    GroupEntity? existing,
  }) async {
    ref.read(hapticsServiceProvider).selectionClick();
    final controller = TextEditingController(text: existing?.name);
    var colorArgb = existing?.colorArgb ?? _groupColors.first;

    await showBlurredDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'New Group' : 'Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  Widget swatch(int c) => GestureDetector(
                    onTap: () => setDialogState(() => colorArgb = c),
                    child: CircleAvatar(
                      backgroundColor: Color(c),
                      radius: 16,
                      child: colorArgb == c
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );

                  Widget row(List<int> colors) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colors.map(swatch).toList(),
                    ),
                  );

                  return Column(
                    children: [
                      row(_groupColors.sublist(0, 5)),
                      row(_groupColors.sublist(5, 10)),
                    ],
                  );
                },
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
                final name = controller.text.trim();
                if (name.isEmpty) return;
                final groups = ref.read(groupListProvider);
                ref.read(groupListProvider.notifier).upsert(
                  GroupEntity(
                    id: existing?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name,
                    colorArgb: colorArgb,
                    sortOrder: existing?.sortOrder ?? groups.length,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: groups.isEmpty
          ? Center(
              child: Text(
                'No custom groups yet.\nTap + to create one (e.g. Travel, Dining).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      group.colorArgb ?? _groupColors.first,
                    ),
                  ),
                  title: Text(group.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(hapticsServiceProvider).selectionClick();
                      ref.read(groupListProvider.notifier).remove(group.id);
                    },
                  ),
                  onTap: () => _showEditor(context, ref, existing: group),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
