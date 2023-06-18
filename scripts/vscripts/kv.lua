KeyValues = {
    -- ItemsRarityKv = LoadKeyValues("scripts/npc/kv/items_rarity.kv"),
    -- CardTypeKv = LoadKeyValues("scripts/npc/kv/card_type.kv"),
    -- QualificationAbilitiesKv = LoadKeyValues("scripts/npc/kv/qualification_abilities.kv"),
    -- ReservoirsKv = LoadKeyValues("scripts/npc/kv/reservoirs.kv"),
    -- PoolsKv = LoadKeyValues("scripts/npc/kv/pools.kv"),
    -- DrawKv = LoadKeyValues("scripts/npc/kv/draw.kv"),
    -- CrystalShopKv = LoadKeyValues("scripts/npc/kv/crystal_shop.kv"),
    -- AssetModifiersKv = LoadKeyValues("scripts/npc/asset_modifiers.kv"),
    -- HeroIDKv = LoadKeyValues("scripts/npc/kv/hero_id.kv"),
    -- PermanentModifiersKv = LoadKeyValues("scripts/npc/kv/permanent_modifiers.kv"),
    -- CourierKv = LoadKeyValues("scripts/npc/courier.kv"),
    -- WaveKv = LoadKeyValues("scripts/npc/kv/wave.kv"),
    -- EndlessKv = LoadKeyValues("scripts/npc/kv/endless.kv"),
    -- TowerUpgradesKv = LoadKeyValues("scripts/npc/kv/npc_tower_upgrades.kv"),
    -- NpcEnemyKv = TableOverride(LoadKeyValues("scripts/npc/kv/npc_enemy.kv"), LoadKeyValues("scripts/npc/kv/npc_endless.kv")),
    --
    UnitsKv = LoadKeyValues("scripts/npc/npc_units_custom.txt"),
    AbilitiesKv = TableOverride(
    TableOverride(
    LoadKeyValues("scripts/npc/npc_abilities.txt"),
    LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    ),
    LoadKeyValues("scripts/npc/npc_abilities_override.txt")
    ),
    ItemsKvCustom = LoadKeyValues("scripts/npc/npc_items_custom.txt"),
    ItemsKv = TableOverride(LoadKeyValues("scripts/npc/items.txt"), LoadKeyValues("scripts/npc/npc_items_custom.txt")),
    SkinsKv = LoadKeyValues("scripts/npc/skins.txt"),
    HeroListKv = LoadKeyValues("scripts/npc/herolist.txt"),
    -- HeroAbilityKv = TableOverride(LoadKeyValues("scripts/npc/npc_heroes.txt"), LoadKeyValues("scripts/npc/npc_heroes_custom.txt")),
    HeroAbilityKv = LoadKeyValues("scripts/npc/npc_heroes_custom.txt"),
    SoldierAbilityKv = LoadKeyValues("scripts/npc/npc_units_custom.txt"),
    CardKv = LoadKeyValues("scripts/npc/cardlist.txt")
}