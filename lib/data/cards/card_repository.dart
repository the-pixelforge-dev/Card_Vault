import 'package:hive_ce/hive.dart';

import '../../domain/card/card_entity.dart';
import '../../domain/card/card_network.dart';
import '../../domain/card/card_type.dart';
import 'card_hive_model.dart';

class CardRepository {
  CardRepository(this._box);

  static const boxName = 'cards';

  final Box<CardHiveModel> _box;

  List<CardEntity> getAll() {
    final entities = _box.values.map(_toEntity).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  Future<void> save(CardEntity card) async {
    final model = _toModel(card);
    await _box.put(card.id, model);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> reorder(List<String> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      final model = _box.get(orderedIds[i]);
      if (model != null) {
        model.sortOrder = i;
        await model.save();
      }
    }
  }

  CardEntity _toEntity(CardHiveModel m) => CardEntity(
    id: m.id,
    cardholderName: m.cardholderName,
    cardNumber: m.cardNumber,
    expiryMonthYear: m.expiryMonthYear,
    cvv: m.cvv,
    issuerName: m.issuerName,
    network: CardNetwork.values.byName(m.network),
    cardType: CardType.values.byName(m.cardType),
    nickname: m.nickname,
    colorArgb: m.colorArgb,
    artworkImagePath: m.artworkImagePath,
    cardVariant: m.cardVariant,
    creditLimit: m.creditLimit,
    pin: m.pin,
    rewardsText: m.rewardsText,
    bestForText: m.bestForText,
    rewardsUrl: m.rewardsUrl,
    paymentUrl: m.paymentUrl,
    managementUrl: m.managementUrl,
    customerServiceUrl: m.customerServiceUrl,
    customFields: Map<String, String>.from(m.customFields),
    notes: m.notes,
    groupIds: List<String>.from(m.groupIds),
    sortOrder: m.sortOrder,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
  );

  CardHiveModel _toModel(CardEntity e) => CardHiveModel(
    id: e.id,
    cardholderName: e.cardholderName,
    cardNumber: e.cardNumber,
    expiryMonthYear: e.expiryMonthYear,
    cvv: e.cvv,
    issuerName: e.issuerName,
    network: e.network.name,
    cardType: e.cardType.name,
    nickname: e.nickname,
    colorArgb: e.colorArgb,
    artworkImagePath: e.artworkImagePath,
    cardVariant: e.cardVariant,
    creditLimit: e.creditLimit,
    pin: e.pin,
    rewardsText: e.rewardsText,
    bestForText: e.bestForText,
    rewardsUrl: e.rewardsUrl,
    paymentUrl: e.paymentUrl,
    managementUrl: e.managementUrl,
    customerServiceUrl: e.customerServiceUrl,
    customFields: Map<String, String>.from(e.customFields),
    notes: e.notes,
    groupIds: List<String>.from(e.groupIds),
    sortOrder: e.sortOrder,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
