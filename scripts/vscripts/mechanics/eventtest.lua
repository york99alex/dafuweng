
if not GameMode then
    GameMode = {}
end
function GameMode:StartEventTest()
    ListenToGameEvent("team_info", Dynamic_Wrap(GameMode, 'On_team_info'), self)
    ListenToGameEvent("team_score", Dynamic_Wrap(GameMode, 'On_team_score'), self)
    ListenToGameEvent("teamplay_broadcast_audio", Dynamic_Wrap(GameMode, 'On_teamplay_broadcast_audio'), self)
    ListenToGameEvent("player_team", Dynamic_Wrap(GameMode, 'On_player_team'), self)
    ListenToGameEvent("player_class", Dynamic_Wrap(GameMode, 'On_player_class'), self)
    ListenToGameEvent("player_death", Dynamic_Wrap(GameMode, 'On_player_death '), self)
    ListenToGameEvent("player_hurt", Dynamic_Wrap(GameMode, 'On_player_hurt '), self)
    ListenToGameEvent("player_chat", Dynamic_Wrap(GameMode, 'On_player_chat '), self)
    ListenToGameEvent("player_score", Dynamic_Wrap(GameMode, 'On_player_score'), self)
    ListenToGameEvent("player_spawn", Dynamic_Wrap(GameMode, 'On_player_spawn'), self)
    ListenToGameEvent("player_shoot", Dynamic_Wrap(GameMode, 'On_player_shoot'), self)
    ListenToGameEvent("player_use", Dynamic_Wrap(GameMode, 'On_player_use'), self)
    ListenToGameEvent("player_changename", Dynamic_Wrap(GameMode, 'On_player_changename'), self)
    ListenToGameEvent("player_hintmessage", Dynamic_Wrap(GameMode, 'On_player_hintmessage'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'On_player_reconnected '), self)
    ListenToGameEvent("game_init", Dynamic_Wrap(GameMode, 'On_game_init'), self)
    ListenToGameEvent("game_newmap", Dynamic_Wrap(GameMode, 'On_game_newmap'), self)
    ListenToGameEvent("game_start", Dynamic_Wrap(GameMode, 'On_game_start'), self)
    ListenToGameEvent("game_end", Dynamic_Wrap(GameMode, 'On_game_end'), self)
    ListenToGameEvent("round_start", Dynamic_Wrap(GameMode, 'On_round_start'), self)
    ListenToGameEvent("round_end", Dynamic_Wrap(GameMode, 'On_round_end'), self)
    ListenToGameEvent("round_start_pre_entity", Dynamic_Wrap(GameMode, 'On_round_start_pre_entity'), self)
    ListenToGameEvent("teamplay_round_start", Dynamic_Wrap(GameMode, 'On_teamplay_round_start'), self)
    ListenToGameEvent("hostname_changed", Dynamic_Wrap(GameMode, 'On_hostname_changed'), self)
    ListenToGameEvent("difficulty_changed", Dynamic_Wrap(GameMode, 'On_difficulty_changed'), self)
    ListenToGameEvent("finale_start", Dynamic_Wrap(GameMode, 'On_finale_start'), self)
    ListenToGameEvent("game_message", Dynamic_Wrap(GameMode, 'On_game_message'), self)
    ListenToGameEvent("break_breakable", Dynamic_Wrap(GameMode, 'On_break_breakable'), self)
    ListenToGameEvent("break_prop", Dynamic_Wrap(GameMode, 'On_break_prop'), self)
    --ListenToGameEvent("npc_spawned", Dynamic_Wrap(GameMode, 'On_npc_spawned'), self)
    ListenToGameEvent("npc_replaced", Dynamic_Wrap(GameMode, 'On_npc_replaced'), self)
    --ListenToGameEvent("entity_killed", Dynamic_Wrap(GameMode, 'On_entity_killed'), self)
    --ListenToGameEvent("entity_hurt", Dynamic_Wrap(GameMode, 'On_entity_hurt'), self)
    ListenToGameEvent("bonus_updated", Dynamic_Wrap(GameMode, 'On_bonus_updated'), self)
    ListenToGameEvent("player_stats_updated", Dynamic_Wrap(GameMode, 'On_player_stats_updated'), self)
    ListenToGameEvent("achievement_event", Dynamic_Wrap(GameMode, 'On_achievement_event'), self)
    ListenToGameEvent("achievement_earned", Dynamic_Wrap(GameMode, 'On_achievement_earned'), self)
    ListenToGameEvent("achievement_write_failed", Dynamic_Wrap(GameMode, 'On_achievement_write_failed'), self)
    ListenToGameEvent("physgun_pickup", Dynamic_Wrap(GameMode, 'On_physgun_pickup'), self)
    ListenToGameEvent("flare_ignite_npc", Dynamic_Wrap(GameMode, 'On_flare_ignite_npc'), self)
    ListenToGameEvent("helicopter_grenade_punt_miss", Dynamic_Wrap(GameMode, 'On_helicopter_grenade_punt_miss'), self)
    ListenToGameEvent("user_data_downloaded", Dynamic_Wrap(GameMode, 'On_user_data_downloaded'), self)
    ListenToGameEvent("ragdoll_dissolved", Dynamic_Wrap(GameMode, 'On_ragdoll_dissolved'), self)
    ListenToGameEvent("gameinstructor_draw", Dynamic_Wrap(GameMode, 'On_gameinstructor_draw'), self)
    ListenToGameEvent("gameinstructor_nodraw", Dynamic_Wrap(GameMode, 'On_gameinstructor_nodraw'), self)
    ListenToGameEvent("map_transition", Dynamic_Wrap(GameMode, 'On_map_transition'), self)
    ListenToGameEvent("instructor_server_hint_create", Dynamic_Wrap(GameMode, 'On_instructor_server_hint_create'), self)
    ListenToGameEvent("instructor_server_hint_stop", Dynamic_Wrap(GameMode, 'On_instructor_server_hint_stop'), self)
    ListenToGameEvent("chat_new_message", Dynamic_Wrap(GameMode, 'On_chat_new_message'), self)
    ListenToGameEvent("chat_members_changed", Dynamic_Wrap(GameMode, 'On_chat_members_changed'), self)
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GameMode, 'On_game_rules_state_change'), self)
    ListenToGameEvent("inventory_updated", Dynamic_Wrap(GameMode, 'On_inventory_updated'), self)
    ListenToGameEvent("cart_updated", Dynamic_Wrap(GameMode, 'On_cart_updated'), self)
    ListenToGameEvent("store_pricesheet_updated", Dynamic_Wrap(GameMode, 'On_store_pricesheet_updated'), self)
    ListenToGameEvent("gc_connected", Dynamic_Wrap(GameMode, 'On_gc_connected'), self)
    ListenToGameEvent("item_schema_initialized", Dynamic_Wrap(GameMode, 'On_item_schema_initialized'), self)
    ListenToGameEvent("drop_rate_modified", Dynamic_Wrap(GameMode, 'On_drop_rate_modified'), self)
    ListenToGameEvent("event_ticket_modified", Dynamic_Wrap(GameMode, 'On_event_ticket_modified'), self)
    ListenToGameEvent("modifier_event", Dynamic_Wrap(GameMode, 'On_modifier_event'), self)
    ListenToGameEvent("dota_player_kill", Dynamic_Wrap(GameMode, 'On_dota_player_kill'), self)
    ListenToGameEvent("dota_player_deny", Dynamic_Wrap(GameMode, 'On_dota_player_deny'), self)
    ListenToGameEvent("dota_barracks_kill", Dynamic_Wrap(GameMode, 'On_dota_barracks_kill'), self)
    ListenToGameEvent("dota_tower_kill", Dynamic_Wrap(GameMode, 'On_dota_tower_kill'), self)
    ListenToGameEvent("dota_roshan_kill", Dynamic_Wrap(GameMode, 'On_dota_roshan_kill'), self)
    ListenToGameEvent("dota_courier_lost", Dynamic_Wrap(GameMode, 'On_dota_courier_lost'), self)
    ListenToGameEvent("dota_courier_respawned", Dynamic_Wrap(GameMode, 'On_dota_courier_respawned'), self)
    ListenToGameEvent("dota_glyph_used", Dynamic_Wrap(GameMode, 'On_dota_glyph_used'), self)
    ListenToGameEvent("dota_super_creeps", Dynamic_Wrap(GameMode, 'On_dota_super_creeps'), self)
    ListenToGameEvent("dota_item_purchase", Dynamic_Wrap(GameMode, 'On_dota_item_purchase'), self)
    ListenToGameEvent("dota_item_gifted", Dynamic_Wrap(GameMode, 'On_dota_item_gifted'), self)
    ListenToGameEvent("dota_rune_pickup", Dynamic_Wrap(GameMode, 'On_dota_rune_pickup'), self)
    ListenToGameEvent("dota_rune_spotted", Dynamic_Wrap(GameMode, 'On_dota_rune_spotted'), self)
    ListenToGameEvent("dota_item_spotted", Dynamic_Wrap(GameMode, 'On_dota_item_spotted'), self)
    ListenToGameEvent("dota_no_battle_points", Dynamic_Wrap(GameMode, 'On_dota_no_battle_points'), self)
    ListenToGameEvent("dota_chat_informational", Dynamic_Wrap(GameMode, 'On_dota_chat_informational'), self)
    ListenToGameEvent("dota_action_item", Dynamic_Wrap(GameMode, 'On_dota_action_item'), self)
    ListenToGameEvent("dota_chat_ban_notification", Dynamic_Wrap(GameMode, 'On_dota_chat_ban_notification'), self)
    ListenToGameEvent("dota_chat_event", Dynamic_Wrap(GameMode, 'On_dota_chat_event'), self)
    ListenToGameEvent("dota_chat_timed_reward", Dynamic_Wrap(GameMode, 'On_dota_chat_timed_reward'), self)
    ListenToGameEvent("dota_pause_event", Dynamic_Wrap(GameMode, 'On_dota_pause_event'), self)
    ListenToGameEvent("dota_chat_kill_streak", Dynamic_Wrap(GameMode, 'On_dota_chat_kill_streak'), self)
    ListenToGameEvent("dota_chat_first_blood", Dynamic_Wrap(GameMode, 'On_dota_chat_first_blood'), self)
    ListenToGameEvent("dota_player_update_hero_selection", Dynamic_Wrap(GameMode, 'On_dota_player_update_hero_selection'), self)
    ListenToGameEvent("dota_player_update_selected_unit", Dynamic_Wrap(GameMode, 'On_dota_player_update_selected_unit'), self)
    ListenToGameEvent("dota_player_update_query_unit", Dynamic_Wrap(GameMode, 'On_dota_player_update_query_unit'), self)
    ListenToGameEvent("dota_player_update_killcam_unit", Dynamic_Wrap(GameMode, 'On_dota_player_update_killcam_unit'), self)
    ListenToGameEvent("dota_player_take_tower_damage", Dynamic_Wrap(GameMode, 'On_dota_player_take_tower_damage'), self)
    ListenToGameEvent("dota_hud_error_message", Dynamic_Wrap(GameMode, 'On_dota_hud_error_message'), self)
    ListenToGameEvent("dota_action_success", Dynamic_Wrap(GameMode, 'On_dota_action_success'), self)
    ListenToGameEvent("dota_starting_position_changed", Dynamic_Wrap(GameMode, 'On_dota_starting_position_changed'), self)
    ListenToGameEvent("dota_money_changed", Dynamic_Wrap(GameMode, 'On_dota_money_changed'), self)
    ListenToGameEvent("dota_enemy_money_changed", Dynamic_Wrap(GameMode, 'On_dota_enemy_money_changed'), self)
    ListenToGameEvent("dota_portrait_unit_stats_changed", Dynamic_Wrap(GameMode, 'On_dota_portrait_unit_stats_changed'), self)
    ListenToGameEvent("dota_portrait_unit_modifiers_changed", Dynamic_Wrap(GameMode, 'On_dota_portrait_unit_modifiers_changed'), self)
    ListenToGameEvent("dota_force_portrait_update", Dynamic_Wrap(GameMode, 'On_dota_force_portrait_update'), self)
    ListenToGameEvent("dota_inventory_changed", Dynamic_Wrap(GameMode, 'On_dota_inventory_changed'), self)
    ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(GameMode, 'On_dota_item_picked_up'), self)
    ListenToGameEvent("dota_inventory_item_changed", Dynamic_Wrap(GameMode, 'On_dota_inventory_item_changed'), self)
    ListenToGameEvent("dota_ability_changed", Dynamic_Wrap(GameMode, 'On_dota_ability_changed'), self)
    ListenToGameEvent("dota_portrait_ability_layout_changed", Dynamic_Wrap(GameMode, 'On_dota_portrait_ability_layout_changed'), self)
    ListenToGameEvent("dota_inventory_item_added", Dynamic_Wrap(GameMode, 'On_dota_inventory_item_added'), self)
    ListenToGameEvent("dota_inventory_changed_query_unit", Dynamic_Wrap(GameMode, 'On_dota_inventory_changed_query_unit'), self)
    ListenToGameEvent("dota_link_clicked", Dynamic_Wrap(GameMode, 'On_dota_link_clicked'), self)
    ListenToGameEvent("dota_set_quick_buy", Dynamic_Wrap(GameMode, 'On_dota_set_quick_buy'), self)
    ListenToGameEvent("dota_quick_buy_changed", Dynamic_Wrap(GameMode, 'On_dota_quick_buy_changed'), self)
    ListenToGameEvent("dota_player_shop_changed", Dynamic_Wrap(GameMode, 'On_dota_player_shop_changed'), self)
    ListenToGameEvent("dota_player_show_killcam", Dynamic_Wrap(GameMode, 'On_dota_player_show_killcam'), self)
    ListenToGameEvent("dota_player_show_minikillcam", Dynamic_Wrap(GameMode, 'On_dota_player_show_minikillcam'), self)
    ListenToGameEvent("gc_user_session_created", Dynamic_Wrap(GameMode, 'On_gc_user_session_created'), self)
    ListenToGameEvent("team_data_updated", Dynamic_Wrap(GameMode, 'On_team_data_updated'), self)
    ListenToGameEvent("guild_data_updated", Dynamic_Wrap(GameMode, 'On_guild_data_updated'), self)
    ListenToGameEvent("guild_open_parties_updated", Dynamic_Wrap(GameMode, 'On_guild_open_parties_updated'), self)
    ListenToGameEvent("fantasy_updated", Dynamic_Wrap(GameMode, 'On_fantasy_updated'), self)
    ListenToGameEvent("fantasy_league_changed", Dynamic_Wrap(GameMode, 'On_fantasy_league_changed'), self)
    ListenToGameEvent("fantasy_score_info_changed", Dynamic_Wrap(GameMode, 'On_fantasy_score_info_changed'), self)
    ListenToGameEvent("player_info_updated", Dynamic_Wrap(GameMode, 'On_player_info_updated'), self)
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(GameMode, 'On_game_rules_state_change'), self)
    ListenToGameEvent("match_history_updated", Dynamic_Wrap(GameMode, 'On_match_history_updated'), self)
    ListenToGameEvent("match_details_updated", Dynamic_Wrap(GameMode, 'On_match_details_updated'), self)
    ListenToGameEvent("live_games_updated", Dynamic_Wrap(GameMode, 'On_live_games_updated'), self)
    ListenToGameEvent("recent_matches_updated", Dynamic_Wrap(GameMode, 'On_recent_matches_updated'), self)
    ListenToGameEvent("news_updated", Dynamic_Wrap(GameMode, 'On_news_updated'), self)
    ListenToGameEvent("persona_updated", Dynamic_Wrap(GameMode, 'On_persona_updated'), self)
    ListenToGameEvent("tournament_state_updated", Dynamic_Wrap(GameMode, 'On_tournament_state_updated'), self)
    ListenToGameEvent("party_updated", Dynamic_Wrap(GameMode, 'On_party_updated'), self)
    ListenToGameEvent("lobby_updated", Dynamic_Wrap(GameMode, 'On_lobby_updated'), self)
    ListenToGameEvent("dashboard_caches_cleared", Dynamic_Wrap(GameMode, 'On_dashboard_caches_cleared'), self)
    ListenToGameEvent("last_hit", Dynamic_Wrap(GameMode, 'On_last_hit'), self)
    ListenToGameEvent("player_completed_game", Dynamic_Wrap(GameMode, 'On_player_completed_game'), self)
    --ListenToGameEvent("dota_combatlog", Dynamic_Wrap(GameMode, 'On_dota_combatlog'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'On_player_reconnected'), self)
    ListenToGameEvent("nommed_tree", Dynamic_Wrap(GameMode, 'On_nommed_tree'), self)
    ListenToGameEvent("dota_rune_activated_server", Dynamic_Wrap(GameMode, 'On_dota_rune_activated_server'), self)
    ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(GameMode, 'On_dota_player_gained_level'), self)
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(GameMode, 'On_dota_player_pick_hero'), self)
    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(GameMode, 'On_dota_player_learned_ability'), self)
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(GameMode, 'On_dota_player_used_ability'), self)
    ListenToGameEvent("dota_non_player_used_ability", Dynamic_Wrap(GameMode, 'On_dota_non_player_used_ability'), self)
    ListenToGameEvent("dota_ability_channel_finished", Dynamic_Wrap(GameMode, 'On_dota_ability_channel_finished'), self)
    ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(GameMode, 'On_dota_holdout_revive_complete'), self)
    ListenToGameEvent("dota_player_killed", Dynamic_Wrap(GameMode, 'On_dota_player_killed'), self)
    ListenToGameEvent("bindpanel_open", Dynamic_Wrap(GameMode, 'On_bindpanel_open'), self)
    ListenToGameEvent("bindpanel_close", Dynamic_Wrap(GameMode, 'On_bindpanel_close'), self)
    ListenToGameEvent("keybind_changed", Dynamic_Wrap(GameMode, 'On_keybind_changed'), self)
    ListenToGameEvent("dota_item_drag_begin", Dynamic_Wrap(GameMode, 'On_dota_item_drag_begin'), self)
    ListenToGameEvent("dota_item_drag_end", Dynamic_Wrap(GameMode, 'On_dota_item_drag_end'), self)
    ListenToGameEvent("dota_shop_item_drag_begin", Dynamic_Wrap(GameMode, 'On_dota_shop_item_drag_begin'), self)
    ListenToGameEvent("dota_shop_item_drag_end", Dynamic_Wrap(GameMode, 'On_dota_shop_item_drag_end'), self)
    ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(GameMode, 'On_dota_item_purchased'), self)
    ListenToGameEvent("dota_item_used", Dynamic_Wrap(GameMode, 'On_dota_item_used'), self)
    ListenToGameEvent("dota_item_auto_purchase", Dynamic_Wrap(GameMode, 'On_dota_item_auto_purchase'), self)
    ListenToGameEvent("dota_unit_event", Dynamic_Wrap(GameMode, 'On_dota_unit_event'), self)
    ListenToGameEvent("dota_quest_started", Dynamic_Wrap(GameMode, 'On_dota_quest_started'), self)
    ListenToGameEvent("dota_quest_completed", Dynamic_Wrap(GameMode, 'On_dota_quest_completed'), self)
    ListenToGameEvent("gameui_activated", Dynamic_Wrap(GameMode, 'On_gameui_activated'), self)
    ListenToGameEvent("gameui_hidden", Dynamic_Wrap(GameMode, 'On_gameui_hidden'), self)
    ListenToGameEvent("player_fullyjoined", Dynamic_Wrap(GameMode, 'On_player_fullyjoined'), self)
    ListenToGameEvent("dota_spectate_hero", Dynamic_Wrap(GameMode, 'On_dota_spectate_hero'), self)
    ListenToGameEvent("dota_match_done", Dynamic_Wrap(GameMode, 'On_dota_match_done'), self)
    ListenToGameEvent("dota_match_done_client", Dynamic_Wrap(GameMode, 'On_dota_match_done_client'), self)
    ListenToGameEvent("set_instructor_group_enabled", Dynamic_Wrap(GameMode, 'On_set_instructor_group_enabled'), self)
    ListenToGameEvent("joined_chat_channel", Dynamic_Wrap(GameMode, 'On_joined_chat_channel'), self)
    ListenToGameEvent("left_chat_channel", Dynamic_Wrap(GameMode, 'On_left_chat_channel'), self)
    ListenToGameEvent("gc_chat_channel_list_updated", Dynamic_Wrap(GameMode, 'On_gc_chat_channel_list_updated'), self)
    ListenToGameEvent("today_messages_updated", Dynamic_Wrap(GameMode, 'On_today_messages_updated'), self)
    ListenToGameEvent("file_downloaded", Dynamic_Wrap(GameMode, 'On_file_downloaded'), self)
    ListenToGameEvent("player_report_counts_updated", Dynamic_Wrap(GameMode, 'On_player_report_counts_updated'), self)
    ListenToGameEvent("scaleform_file_download_complete", Dynamic_Wrap(GameMode, 'On_scaleform_file_download_complete'), self)
    ListenToGameEvent("item_purchased", Dynamic_Wrap(GameMode, 'On_item_purchased'), self)
    ListenToGameEvent("gc_mismatched_version", Dynamic_Wrap(GameMode, 'On_gc_mismatched_version'), self)
    ListenToGameEvent("demo_skip", Dynamic_Wrap(GameMode, 'On_demo_skip'), self)
    ListenToGameEvent("demo_start", Dynamic_Wrap(GameMode, 'On_demo_start'), self)
    ListenToGameEvent("demo_stop", Dynamic_Wrap(GameMode, 'On_demo_stop'), self)
    ListenToGameEvent("map_shutdown", Dynamic_Wrap(GameMode, 'On_map_shutdown'), self)
    ListenToGameEvent("dota_workshop_fileselected", Dynamic_Wrap(GameMode, 'On_dota_workshop_fileselected'), self)
    ListenToGameEvent("dota_workshop_filecanceled", Dynamic_Wrap(GameMode, 'On_dota_workshop_filecanceled'), self)
    ListenToGameEvent("rich_presence_updated", Dynamic_Wrap(GameMode, 'On_rich_presence_updated'), self)
    ListenToGameEvent("dota_hero_random", Dynamic_Wrap(GameMode, 'On_dota_hero_random'), self)
    ListenToGameEvent("dota_rd_chat_turn", Dynamic_Wrap(GameMode, 'On_dota_rd_chat_turn'), self)
    ListenToGameEvent("dota_favorite_heroes_updated", Dynamic_Wrap(GameMode, 'On_dota_favorite_heroes_updated'), self)
    ListenToGameEvent("profile_closed", Dynamic_Wrap(GameMode, 'On_profile_closed'), self)
    ListenToGameEvent("item_preview_closed", Dynamic_Wrap(GameMode, 'On_item_preview_closed'), self)
    ListenToGameEvent("dashboard_switched_section", Dynamic_Wrap(GameMode, 'On_dashboard_switched_section'), self)
    ListenToGameEvent("dota_tournament_item_event", Dynamic_Wrap(GameMode, 'On_dota_tournament_item_event'), self)
    ListenToGameEvent("dota_hero_swap", Dynamic_Wrap(GameMode, 'On_dota_hero_swap'), self)
    ListenToGameEvent("dota_reset_suggested_items", Dynamic_Wrap(GameMode, 'On_dota_reset_suggested_items'), self)
    ListenToGameEvent("halloween_high_score_received", Dynamic_Wrap(GameMode, 'On_halloween_high_score_received'), self)
    ListenToGameEvent("halloween_phase_end", Dynamic_Wrap(GameMode, 'On_halloween_phase_end'), self)
    ListenToGameEvent("halloween_high_score_request_failed", Dynamic_Wrap(GameMode, 'On_halloween_high_score_request_failed'), self)
    ListenToGameEvent("dota_hud_skin_changed", Dynamic_Wrap(GameMode, 'On_dota_hud_skin_changed'), self)
    ListenToGameEvent("dota_inventory_player_got_item", Dynamic_Wrap(GameMode, 'On_dota_inventory_player_got_item'), self)
    ListenToGameEvent("player_is_experienced", Dynamic_Wrap(GameMode, 'On_player_is_experienced'), self)
    ListenToGameEvent("player_is_notexperienced", Dynamic_Wrap(GameMode, 'On_player_is_notexperienced'), self)
    ListenToGameEvent("dota_tutorial_lesson_start", Dynamic_Wrap(GameMode, 'On_dota_tutorial_lesson_start'), self)
    ListenToGameEvent("map_location_updated", Dynamic_Wrap(GameMode, 'On_map_location_updated'), self)
    ListenToGameEvent("richpresence_custom_updated", Dynamic_Wrap(GameMode, 'On_richpresence_custom_updated'), self)
    ListenToGameEvent("game_end_visible", Dynamic_Wrap(GameMode, 'On_game_end_visible'), self)
    ListenToGameEvent("antiaddiction_update", Dynamic_Wrap(GameMode, 'On_antiaddiction_update'), self)
    ListenToGameEvent("highlight_hud_element", Dynamic_Wrap(GameMode, 'On_highlight_hud_element'), self)
    ListenToGameEvent("hide_highlight_hud_element", Dynamic_Wrap(GameMode, 'On_hide_highlight_hud_element'), self)
    ListenToGameEvent("intro_video_finished", Dynamic_Wrap(GameMode, 'On_intro_video_finished'), self)
    ListenToGameEvent("matchmaking_status_visibility_changed", Dynamic_Wrap(GameMode, 'On_matchmaking_status_visibility_changed'), self)
    ListenToGameEvent("practice_lobby_visibility_changed", Dynamic_Wrap(GameMode, 'On_practice_lobby_visibility_changed'), self)
    ListenToGameEvent("dota_courier_transfer_item", Dynamic_Wrap(GameMode, 'On_dota_courier_transfer_item'), self)
    ListenToGameEvent("full_ui_unlocked", Dynamic_Wrap(GameMode, 'On_full_ui_unlocked'), self)
    ListenToGameEvent("client_connectionless_packet", Dynamic_Wrap(GameMode, 'On_client_connectionless_packet'), self)
    ListenToGameEvent("hero_selector_preview_set", Dynamic_Wrap(GameMode, 'On_hero_selector_preview_set'), self)
    ListenToGameEvent("antiaddiction_toast", Dynamic_Wrap(GameMode, 'On_antiaddiction_toast'), self)
    ListenToGameEvent("hero_picker_shown", Dynamic_Wrap(GameMode, 'On_hero_picker_shown'), self)
    ListenToGameEvent("hero_picker_hidden", Dynamic_Wrap(GameMode, 'On_hero_picker_hidden'), self)
    ListenToGameEvent("dota_local_quickbuy_changed", Dynamic_Wrap(GameMode, 'On_dota_local_quickbuy_changed'), self)
    ListenToGameEvent("show_center_message", Dynamic_Wrap(GameMode, 'On_show_center_message'), self)
    ListenToGameEvent("hud_flip_changed", Dynamic_Wrap(GameMode, 'On_hud_flip_changed'), self)
    ListenToGameEvent("frosty_points_updated", Dynamic_Wrap(GameMode, 'On_frosty_points_updated'), self)
    ListenToGameEvent("defeated", Dynamic_Wrap(GameMode, 'On_defeated'), self)
    ListenToGameEvent("reset_defeated", Dynamic_Wrap(GameMode, 'On_reset_defeated'), self)
    ListenToGameEvent("booster_state_updated", Dynamic_Wrap(GameMode, 'On_booster_state_updated'), self)
    ListenToGameEvent("event_points_updated", Dynamic_Wrap(GameMode, 'On_event_points_updated'), self)
    ListenToGameEvent("local_player_event_points", Dynamic_Wrap(GameMode, 'On_local_player_event_points'), self)
    ListenToGameEvent("custom_game_difficulty", Dynamic_Wrap(GameMode, 'On_custom_game_difficulty'), self)
    ListenToGameEvent("tree_cut", Dynamic_Wrap(GameMode, 'On_tree_cut'), self)
    ListenToGameEvent("ugc_details_arrived", Dynamic_Wrap(GameMode, 'On_ugc_details_arrived'), self)
    ListenToGameEvent("ugc_subscribed", Dynamic_Wrap(GameMode, 'On_ugc_subscribed'), self)
    ListenToGameEvent("ugc_unsubscribed", Dynamic_Wrap(GameMode, 'On_ugc_unsubscribed'), self)
    ListenToGameEvent("prizepool_received", Dynamic_Wrap(GameMode, 'On_prizepool_received'), self)
    ListenToGameEvent("microtransaction_success", Dynamic_Wrap(GameMode, 'On_microtransaction_success'), self)
    ListenToGameEvent("dota_rubick_ability_steal", Dynamic_Wrap(GameMode, 'On_dota_rubick_ability_steal'), self)
    ListenToGameEvent("compendium_event_actions_loaded", Dynamic_Wrap(GameMode, 'On_compendium_event_actions_loaded'), self)
    ListenToGameEvent("compendium_selections_loaded", Dynamic_Wrap(GameMode, 'On_compendium_selections_loaded'), self)
    ListenToGameEvent("compendium_set_selection_failed", Dynamic_Wrap(GameMode, 'On_compendium_set_selection_failed'), self)
    ListenToGameEvent("community_cached_names_updated", Dynamic_Wrap(GameMode, 'On_community_cached_names_updated'), self)
    ListenToGameEvent("dota_team_kill_credit", Dynamic_Wrap(GameMode, 'On_dota_team_kill_credit'), self)

    ListenToGameEvent("dota_effigy_kill", Dynamic_Wrap(GameMode, 'On_dota_effigy_kill'), self)
    ListenToGameEvent("dota_chat_assassin_announce", Dynamic_Wrap(GameMode, 'On_dota_chat_assassin_announce'), self)
    ListenToGameEvent("dota_chat_assassin_denied", Dynamic_Wrap(GameMode, 'On_dota_chat_assassin_denied'), self)
    ListenToGameEvent("dota_chat_assassin_success", Dynamic_Wrap(GameMode, 'On_dota_chat_assassin_success'), self)
    ListenToGameEvent("player_info_individual_updated", Dynamic_Wrap(GameMode, 'On_player_info_individual_updated'), self)
    ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(GameMode, 'On_dota_player_begin_cast'), self)
    ListenToGameEvent("dota_non_player_begin_cast", Dynamic_Wrap(GameMode, 'On_dota_non_player_begin_cast'), self)
    ListenToGameEvent("dota_item_combined", Dynamic_Wrap(GameMode, 'On_dota_item_combined'), self)
    ListenToGameEvent("profile_opened", Dynamic_Wrap(GameMode, 'On_profile_opened'), self)
    ListenToGameEvent("dota_tutorial_task_advance", Dynamic_Wrap(GameMode, 'On_dota_tutorial_task_advance'), self)
    ListenToGameEvent("dota_tutorial_shop_toggled", Dynamic_Wrap(GameMode, 'On_dota_tutorial_shop_toggled'), self)
    ListenToGameEvent("ugc_download_requested", Dynamic_Wrap(GameMode, 'On_ugc_download_requested'), self)
    ListenToGameEvent("ugc_installed", Dynamic_Wrap(GameMode, 'On_ugc_installed'), self)
    ListenToGameEvent("compendium_trophies_loaded", Dynamic_Wrap(GameMode, 'On_compendium_trophies_loaded'), self)
    ListenToGameEvent("spec_item_pickup", Dynamic_Wrap(GameMode, 'On_spec_item_pickup'), self)
    ListenToGameEvent("spec_aegis_reclaim_time", Dynamic_Wrap(GameMode, 'On_spec_aegis_reclaim_time'), self)
    ListenToGameEvent("account_trophies_changed", Dynamic_Wrap(GameMode, 'On_account_trophies_changed'), self)
    ListenToGameEvent("account_all_hero_challenge_changed", Dynamic_Wrap(GameMode, 'On_account_all_hero_challenge_changed'), self)
    ListenToGameEvent("team_showcase_ui_update", Dynamic_Wrap(GameMode, 'On_team_showcase_ui_update'), self)
    ListenToGameEvent("ingame_events_changed", Dynamic_Wrap(GameMode, 'On_ingame_events_changed'), self)
    ListenToGameEvent("dota_match_signout", Dynamic_Wrap(GameMode, 'On_dota_match_signout'), self)
    ListenToGameEvent("dota_illusions_created", Dynamic_Wrap(GameMode, 'On_dota_illusions_created'), self)
    ListenToGameEvent("dota_year_beast_killed", Dynamic_Wrap(GameMode, 'On_dota_year_beast_killed'), self)
    ListenToGameEvent("dota_hero_undoselection", Dynamic_Wrap(GameMode, 'On_dota_hero_undoselection'), self)
    ListenToGameEvent("dota_challenge_socache_updated", Dynamic_Wrap(GameMode, 'On_dota_challenge_socache_updated'), self)
    ListenToGameEvent("party_invites_updated", Dynamic_Wrap(GameMode, 'On_party_invites_updated'), self)
    ListenToGameEvent("lobby_invites_updated", Dynamic_Wrap(GameMode, 'On_lobby_invites_updated'), self)
    ListenToGameEvent("custom_game_mode_list_updated", Dynamic_Wrap(GameMode, 'On_custom_game_mode_list_updated'), self)
    ListenToGameEvent("custom_game_lobby_list_updated", Dynamic_Wrap(GameMode, 'On_custom_game_lobby_list_updated'), self)
    ListenToGameEvent("friend_lobby_list_updated", Dynamic_Wrap(GameMode, 'On_friend_lobby_list_updated'), self)
    ListenToGameEvent("dota_team_player_list_changed", Dynamic_Wrap(GameMode, 'On_dota_team_player_list_changed'), self)
    ListenToGameEvent("dota_player_details_changed", Dynamic_Wrap(GameMode, 'On_dota_player_details_changed'), self)
    ListenToGameEvent("player_profile_stats_updated", Dynamic_Wrap(GameMode, 'On_player_profile_stats_updated'), self)
    ListenToGameEvent("custom_game_player_count_updated", Dynamic_Wrap(GameMode, 'On_custom_game_player_count_updated'), self)
    ListenToGameEvent("custom_game_friends_played_updated", Dynamic_Wrap(GameMode, 'On_custom_game_friends_played_updated'), self)
    ListenToGameEvent("custom_games_friends_play_updated", Dynamic_Wrap(GameMode, 'On_custom_games_friends_play_updated'), self)
    ListenToGameEvent("dota_player_update_assigned_hero", Dynamic_Wrap(GameMode, 'On_dota_player_update_assigned_hero'), self)
    ListenToGameEvent("dota_player_hero_selection_dirty", Dynamic_Wrap(GameMode, 'On_dota_player_hero_selection_dirty'), self)
    --ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(GameMode, 'On_dota_npc_goal_reached'), self)
    ListenToGameEvent("dota_player_selected_custom_team", Dynamic_Wrap(GameMode, 'On_dota_player_selected_custom_team'), self)
end

function GameMode:On_team_info(data)
    print("[BAREBONES] team_info")
    DeepPrintTable(data)
end


function GameMode:On_team_score(data)
    print("[BAREBONES] team_score")
    DeepPrintTable(data)
end


function GameMode:On_teamplay_broadcast_audio(data)
    print("[BAREBONES] teamplay_broadcast_audio")
    DeepPrintTable(data)
end


function GameMode:On_player_team(data)
    print("[BAREBONES] player_team")
    DeepPrintTable(data)
end


function GameMode:On_player_class(data)
    print("[BAREBONES] player_class")
    DeepPrintTable(data)
end


function GameMode:On_player_death(data)
    print("[BAREBONES] player_death")
    DeepPrintTable(data)
end


function GameMode:On_player_hurt(data)
    print("[BAREBONES] player_hurt")
    DeepPrintTable(data)
end


function GameMode:On_player_chat(data)
    print("[BAREBONES] player_chat")
    DeepPrintTable(data)
end


function GameMode:On_player_score(data)
    print("[BAREBONES] player_score")
    DeepPrintTable(data)
end


function GameMode:On_player_spawn(data)
    print("[BAREBONES] player_spawn")
    DeepPrintTable(data)
end


function GameMode:On_player_shoot(data)
    print("[BAREBONES] player_shoot")
    DeepPrintTable(data)
end


function GameMode:On_player_use(data)
    print("[BAREBONES] player_use")
    DeepPrintTable(data)
end


function GameMode:On_player_changename(data)
    print("[BAREBONES] player_changename")
    DeepPrintTable(data)
end


function GameMode:On_player_hintmessage(data)
    print("[BAREBONES] player_hintmessage")
    DeepPrintTable(data)
end


function GameMode:On_player_reconnected(data)
    print("[BAREBONES] player_reconnected")
    DeepPrintTable(data)
end


function GameMode:On_game_init(data)
    print("[BAREBONES] game_init")
    DeepPrintTable(data)
end


function GameMode:On_game_newmap(data)
    print("[BAREBONES] game_newmap")
    DeepPrintTable(data)
end


function GameMode:On_game_start(data)
    print("[BAREBONES] game_start")
    DeepPrintTable(data)
end


function GameMode:On_game_end(data)
    print("[BAREBONES] game_end")
    DeepPrintTable(data)
end


function GameMode:On_round_start(data)
    print("[BAREBONES] round_start")
    DeepPrintTable(data)
end


function GameMode:On_round_end(data)
    print("[BAREBONES] round_end")
    DeepPrintTable(data)
end


function GameMode:On_round_start_pre_entity(data)
    print("[BAREBONES] round_start_pre_entity")
    DeepPrintTable(data)
end


function GameMode:On_teamplay_round_start(data)
    print("[BAREBONES] teamplay_round_start")
    DeepPrintTable(data)
end


function GameMode:On_hostname_changed(data)
    print("[BAREBONES] hostname_changed")
    DeepPrintTable(data)
end


function GameMode:On_difficulty_changed(data)
    print("[BAREBONES] difficulty_changed")
    DeepPrintTable(data)
end


function GameMode:On_finale_start(data)
    print("[BAREBONES] finale_start")
    DeepPrintTable(data)
end


function GameMode:On_game_message(data)
    print("[BAREBONES] game_message")
    DeepPrintTable(data)
end


function GameMode:On_break_breakable(data)
    print("[BAREBONES] break_breakable")
    DeepPrintTable(data)
end


function GameMode:On_break_prop(data)
    print("[BAREBONES] break_prop")
    DeepPrintTable(data)
end


function GameMode:On_npc_spawned(data)
    print("[BAREBONES] npc_spawned")
    DeepPrintTable(data)
end


function GameMode:On_npc_replaced(data)
    print("[BAREBONES] npc_replaced")
    DeepPrintTable(data)
end


function GameMode:On_entity_killed(data)
    print("[BAREBONES] entity_killed")
    DeepPrintTable(data)
end


function GameMode:On_entity_hurt(data)
    print("[BAREBONES] entity_hurt")
    DeepPrintTable(data)
end


function GameMode:On_bonus_updated(data)
    print("[BAREBONES] bonus_updated")
    DeepPrintTable(data)
end


function GameMode:On_player_stats_updated(data)
    print("[BAREBONES] player_stats_updated")
    DeepPrintTable(data)
end


function GameMode:On_achievement_event(data)
    print("[BAREBONES] achievement_event")
    DeepPrintTable(data)
end


function GameMode:On_achievement_earned(data)
    print("[BAREBONES] achievement_earned")
    DeepPrintTable(data)
end


function GameMode:On_achievement_write_failed(data)
    print("[BAREBONES] achievement_write_failed")
    DeepPrintTable(data)
end


function GameMode:On_physgun_pickup(data)
    print("[BAREBONES] physgun_pickup")
    DeepPrintTable(data)
end


function GameMode:On_flare_ignite_npc(data)
    print("[BAREBONES] flare_ignite_npc")
    DeepPrintTable(data)
end


function GameMode:On_helicopter_grenade_punt_miss(data)
    print("[BAREBONES] helicopter_grenade_punt_miss")
    DeepPrintTable(data)
end


function GameMode:On_user_data_downloaded(data)
    print("[BAREBONES] user_data_downloaded")
    DeepPrintTable(data)
end


function GameMode:On_ragdoll_dissolved(data)
    print("[BAREBONES] ragdoll_dissolved")
    DeepPrintTable(data)
end


function GameMode:On_gameinstructor_draw(data)
    print("[BAREBONES] gameinstructor_draw")
    DeepPrintTable(data)
end


function GameMode:On_gameinstructor_nodraw(data)
    print("[BAREBONES] gameinstructor_nodraw")
    DeepPrintTable(data)
end


function GameMode:On_map_transition(data)
    print("[BAREBONES] map_transition")
    DeepPrintTable(data)
end


function GameMode:On_instructor_server_hint_create(data)
    print("[BAREBONES] instructor_server_hint_create")
    DeepPrintTable(data)
end


function GameMode:On_instructor_server_hint_stop(data)
    print("[BAREBONES] instructor_server_hint_stop")
    DeepPrintTable(data)
end


function GameMode:On_chat_new_message(data)
    print("[BAREBONES] chat_new_message")
    DeepPrintTable(data)
end


function GameMode:On_chat_members_changed(data)
    print("[BAREBONES] chat_members_changed")
    DeepPrintTable(data)
end


function GameMode:On_game_rules_state_change(data)
    print("[BAREBONES] game_rules_state_change")
    DeepPrintTable(data)
end


function GameMode:On_inventory_updated(data)
    print("[BAREBONES] inventory_updated")
    DeepPrintTable(data)
end


function GameMode:On_cart_updated(data)
    print("[BAREBONES] cart_updated")
    DeepPrintTable(data)
end


function GameMode:On_store_pricesheet_updated(data)
    print("[BAREBONES] store_pricesheet_updated")
    DeepPrintTable(data)
end


function GameMode:On_gc_connected(data)
    print("[BAREBONES] gc_connected")
    DeepPrintTable(data)
end


function GameMode:On_item_schema_initialized(data)
    print("[BAREBONES] item_schema_initialized")
    DeepPrintTable(data)
end


function GameMode:On_drop_rate_modified(data)
    print("[BAREBONES] drop_rate_modified")
    DeepPrintTable(data)
end


function GameMode:On_event_ticket_modified(data)
    print("[BAREBONES] event_ticket_modified")
    DeepPrintTable(data)
end


function GameMode:On_modifier_event(data)
    print("[BAREBONES] modifier_event")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_kill(data)
    print("[BAREBONES] dota_player_kill")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_deny(data)
    print("[BAREBONES] dota_player_deny")
    DeepPrintTable(data)
end


function GameMode:On_dota_barracks_kill(data)
    print("[BAREBONES] dota_barracks_kill")
    DeepPrintTable(data)
end


function GameMode:On_dota_tower_kill(data)
    print("[BAREBONES] dota_tower_kill")
    DeepPrintTable(data)
end


function GameMode:On_dota_roshan_kill(data)
    print("[BAREBONES] dota_roshan_kill")
    DeepPrintTable(data)
end


function GameMode:On_dota_courier_lost(data)
    print("[BAREBONES] dota_courier_lost")
    DeepPrintTable(data)
end


function GameMode:On_dota_courier_respawned(data)
    print("[BAREBONES] dota_courier_respawned")
    DeepPrintTable(data)
end


function GameMode:On_dota_glyph_used(data)
    print("[BAREBONES] dota_glyph_used")
    DeepPrintTable(data)
end


function GameMode:On_dota_super_creeps(data)
    print("[BAREBONES] dota_super_creeps")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_purchase(data)
    print("[BAREBONES] dota_item_purchase")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_gifted(data)
    print("[BAREBONES] dota_item_gifted")
    DeepPrintTable(data)
end


function GameMode:On_dota_rune_pickup(data)
    print("[BAREBONES] dota_rune_pickup")
    DeepPrintTable(data)
end


function GameMode:On_dota_rune_spotted(data)
    print("[BAREBONES] dota_rune_spotted")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_spotted(data)
    print("[BAREBONES] dota_item_spotted")
    DeepPrintTable(data)
end


function GameMode:On_dota_no_battle_points(data)
    print("[BAREBONES] dota_no_battle_points")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_informational(data)
    print("[BAREBONES] dota_chat_informational")
    DeepPrintTable(data)
end


function GameMode:On_dota_action_item(data)
    print("[BAREBONES] dota_action_item")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_ban_notification(data)
    print("[BAREBONES] dota_chat_ban_notification")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_event(data)
    print("[BAREBONES] dota_chat_event")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_timed_reward(data)
    print("[BAREBONES] dota_chat_timed_reward")
    DeepPrintTable(data)
end


function GameMode:On_dota_pause_event(data)
    print("[BAREBONES] dota_pause_event")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_kill_streak(data)
    print("[BAREBONES] dota_chat_kill_streak")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_first_blood(data)
    print("[BAREBONES] dota_chat_first_blood")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_update_hero_selection(data)
    print("[BAREBONES] dota_player_update_hero_selection")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_update_selected_unit(data)
    print("[BAREBONES] dota_player_update_selected_unit")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_update_query_unit(data)
    print("[BAREBONES] dota_player_update_query_unit")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_update_killcam_unit(data)
    print("[BAREBONES] dota_player_update_killcam_unit")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_take_tower_damage(data)
    print("[BAREBONES] dota_player_take_tower_damage")
    DeepPrintTable(data)
end


function GameMode:On_dota_hud_error_message(data)
    print("[BAREBONES] dota_hud_error_message")
    DeepPrintTable(data)
end


function GameMode:On_dota_action_success(data)
    print("[BAREBONES] dota_action_success")
    DeepPrintTable(data)
end


function GameMode:On_dota_starting_position_changed(data)
    print("[BAREBONES] dota_starting_position_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_money_changed(data)
    print("[BAREBONES] dota_money_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_enemy_money_changed(data)
    print("[BAREBONES] dota_enemy_money_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_portrait_unit_stats_changed(data)
    print("[BAREBONES] dota_portrait_unit_stats_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_portrait_unit_modifiers_changed(data)
    print("[BAREBONES] dota_portrait_unit_modifiers_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_force_portrait_update(data)
    print("[BAREBONES] dota_force_portrait_update")
    DeepPrintTable(data)
end


function GameMode:On_dota_inventory_changed(data)
    print("[BAREBONES] dota_inventory_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_picked_up(data)
    print("[BAREBONES] dota_item_picked_up")
    DeepPrintTable(data)
end


function GameMode:On_dota_inventory_item_changed(data)
    print("[BAREBONES] dota_inventory_item_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_ability_changed(data)
    print("[BAREBONES] dota_ability_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_portrait_ability_layout_changed(data)
    print("[BAREBONES] dota_portrait_ability_layout_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_inventory_item_added(data)
    print("[BAREBONES] dota_inventory_item_added")
    DeepPrintTable(data)
end


function GameMode:On_dota_inventory_changed_query_unit(data)
    print("[BAREBONES] dota_inventory_changed_query_unit")
    DeepPrintTable(data)
end


function GameMode:On_dota_link_clicked(data)
    print("[BAREBONES] dota_link_clicked")
    DeepPrintTable(data)
end


function GameMode:On_dota_set_quick_buy(data)
    print("[BAREBONES] dota_set_quick_buy")
    DeepPrintTable(data)
end


function GameMode:On_dota_quick_buy_changed(data)
    print("[BAREBONES] dota_quick_buy_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_shop_changed(data)
    print("[BAREBONES] dota_player_shop_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_show_killcam(data)
    print("[BAREBONES] dota_player_show_killcam")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_show_minikillcam(data)
    print("[BAREBONES] dota_player_show_minikillcam")
    DeepPrintTable(data)
end


function GameMode:On_gc_user_session_created(data)
    print("[BAREBONES] gc_user_session_created")
    DeepPrintTable(data)
end


function GameMode:On_team_data_updated(data)
    print("[BAREBONES] team_data_updated")
    DeepPrintTable(data)
end


function GameMode:On_guild_data_updated(data)
    print("[BAREBONES] guild_data_updated")
    DeepPrintTable(data)
end


function GameMode:On_guild_open_parties_updated(data)
    print("[BAREBONES] guild_open_parties_updated")
    DeepPrintTable(data)
end


function GameMode:On_fantasy_updated(data)
    print("[BAREBONES] fantasy_updated")
    DeepPrintTable(data)
end


function GameMode:On_fantasy_league_changed(data)
    print("[BAREBONES] fantasy_league_changed")
    DeepPrintTable(data)
end


function GameMode:On_fantasy_score_info_changed(data)
    print("[BAREBONES] fantasy_score_info_changed")
    DeepPrintTable(data)
end


function GameMode:On_player_info_updated(data)
    print("[BAREBONES] player_info_updated")
    DeepPrintTable(data)
end


function GameMode:On_game_rules_state_change(data)
    print("[BAREBONES] game_rules_state_change")
    DeepPrintTable(data)
end


function GameMode:On_match_history_updated(data)
    print("[BAREBONES] match_history_updated")
    DeepPrintTable(data)
end


function GameMode:On_match_details_updated(data)
    print("[BAREBONES] match_details_updated")
    DeepPrintTable(data)
end


function GameMode:On_live_games_updated(data)
    print("[BAREBONES] live_games_updated")
    DeepPrintTable(data)
end


function GameMode:On_recent_matches_updated(data)
    print("[BAREBONES] recent_matches_updated")
    DeepPrintTable(data)
end


function GameMode:On_news_updated(data)
    print("[BAREBONES] news_updated")
    DeepPrintTable(data)
end


function GameMode:On_persona_updated(data)
    print("[BAREBONES] persona_updated")
    DeepPrintTable(data)
end


function GameMode:On_tournament_state_updated(data)
    print("[BAREBONES] tournament_state_updated")
    DeepPrintTable(data)
end


function GameMode:On_party_updated(data)
    print("[BAREBONES] party_updated")
    DeepPrintTable(data)
end


function GameMode:On_lobby_updated(data)
    print("[BAREBONES] lobby_updated")
    DeepPrintTable(data)
end


function GameMode:On_dashboard_caches_cleared(data)
    print("[BAREBONES] dashboard_caches_cleared")
    DeepPrintTable(data)
end


function GameMode:On_last_hit(data)
    print("[BAREBONES] last_hit")
    DeepPrintTable(data)
end


function GameMode:On_player_completed_game(data)
    print("[BAREBONES] player_completed_game")
    DeepPrintTable(data)
end

function GameMode:On_dota_combatlog(data)
    print("[BAREBONES] dota_combatlog")
    DeepPrintTable(data)
end


function GameMode:On_player_reconnected(data)
    print("[BAREBONES] player_reconnected")
    DeepPrintTable(data)
end


function GameMode:On_nommed_tree(data)
    print("[BAREBONES] nommed_tree")
    DeepPrintTable(data)
end


function GameMode:On_dota_rune_activated_server(data)
    print("[BAREBONES] dota_rune_activated_server")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_gained_level(data)
    print("[BAREBONES] dota_player_gained_level")
    DeepPrintTable(data)
end

function GameMode:On_dota_player_pick_hero(data)
    print("[BAREBONES] dota_player_pick_hero")
    DeepPrintTable(data)
end

function GameMode:On_dota_player_learned_ability(data)
    print("[BAREBONES] dota_player_learned_ability")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_used_ability(data)
    print("[BAREBONES] dota_player_used_ability")
    DeepPrintTable(data)
end


function GameMode:On_dota_non_player_used_ability(data)
    print("[BAREBONES] dota_non_player_used_ability")
    DeepPrintTable(data)
end


function GameMode:On_dota_ability_channel_finished(data)
    print("[BAREBONES] dota_ability_channel_finished")
    DeepPrintTable(data)
end


function GameMode:On_dota_holdout_revive_complete(data)
    print("[BAREBONES] dota_holdout_revive_complete")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_killed(data)
    print("[BAREBONES] dota_player_killed")
    DeepPrintTable(data)
end


function GameMode:On_bindpanel_open(data)
    print("[BAREBONES] bindpanel_open")
    DeepPrintTable(data)
end


function GameMode:On_bindpanel_close(data)
    print("[BAREBONES] bindpanel_close")
    DeepPrintTable(data)
end


function GameMode:On_keybind_changed(data)
    print("[BAREBONES] keybind_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_drag_begin(data)
    print("[BAREBONES] dota_item_drag_begin")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_drag_end(data)
    print("[BAREBONES] dota_item_drag_end")
    DeepPrintTable(data)
end


function GameMode:On_dota_shop_item_drag_begin(data)
    print("[BAREBONES] dota_shop_item_drag_begin")
    DeepPrintTable(data)
end


function GameMode:On_dota_shop_item_drag_end(data)
    print("[BAREBONES] dota_shop_item_drag_end")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_purchased(data)
    print("[BAREBONES] dota_item_purchased")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_used(data)
    print("[BAREBONES] dota_item_used")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_auto_purchase(data)
    print("[BAREBONES] dota_item_auto_purchase")
    DeepPrintTable(data)
end


function GameMode:On_dota_unit_event(data)
    print("[BAREBONES] dota_unit_event")
    DeepPrintTable(data)
end


function GameMode:On_dota_quest_started(data)
    print("[BAREBONES] dota_quest_started")
    DeepPrintTable(data)
end


function GameMode:On_dota_quest_completed(data)
    print("[BAREBONES] dota_quest_completed")
    DeepPrintTable(data)
end


function GameMode:On_gameui_activated(data)
    print("[BAREBONES] gameui_activated")
    DeepPrintTable(data)
end


function GameMode:On_gameui_hidden(data)
    print("[BAREBONES] gameui_hidden")
    DeepPrintTable(data)
end


function GameMode:On_player_fullyjoined(data)
    print("[BAREBONES] player_fullyjoined")
    DeepPrintTable(data)
end


function GameMode:On_dota_spectate_hero(data)
    print("[BAREBONES] dota_spectate_hero")
    DeepPrintTable(data)
end


function GameMode:On_dota_match_done(data)
    print("[BAREBONES] dota_match_done")
    DeepPrintTable(data)
end


function GameMode:On_dota_match_done_client(data)
    print("[BAREBONES] dota_match_done_client")
    DeepPrintTable(data)
end


function GameMode:On_set_instructor_group_enabled(data)
    print("[BAREBONES] set_instructor_group_enabled")
    DeepPrintTable(data)
end


function GameMode:On_joined_chat_channel(data)
    print("[BAREBONES] joined_chat_channel")
    DeepPrintTable(data)
end


function GameMode:On_left_chat_channel(data)
    print("[BAREBONES] left_chat_channel")
    DeepPrintTable(data)
end


function GameMode:On_gc_chat_channel_list_updated(data)
    print("[BAREBONES] gc_chat_channel_list_updated")
    DeepPrintTable(data)
end


function GameMode:On_today_messages_updated(data)
    print("[BAREBONES] today_messages_updated")
    DeepPrintTable(data)
end


function GameMode:On_file_downloaded(data)
    print("[BAREBONES] file_downloaded")
    DeepPrintTable(data)
end


function GameMode:On_player_report_counts_updated(data)
    print("[BAREBONES] player_report_counts_updated")
    DeepPrintTable(data)
end


function GameMode:On_scaleform_file_download_complete(data)
    print("[BAREBONES] scaleform_file_download_complete")
    DeepPrintTable(data)
end


function GameMode:On_item_purchased(data)
    print("[BAREBONES] item_purchased")
    DeepPrintTable(data)
end


function GameMode:On_gc_mismatched_version(data)
    print("[BAREBONES] gc_mismatched_version")
    DeepPrintTable(data)
end


function GameMode:On_demo_skip(data)
    print("[BAREBONES] demo_skip")
    DeepPrintTable(data)
end


function GameMode:On_demo_start(data)
    print("[BAREBONES] demo_start")
    DeepPrintTable(data)
end


function GameMode:On_demo_stop(data)
    print("[BAREBONES] demo_stop")
    DeepPrintTable(data)
end


function GameMode:On_map_shutdown(data)
    print("[BAREBONES] map_shutdown")
    DeepPrintTable(data)
end


function GameMode:On_dota_workshop_fileselected(data)
    print("[BAREBONES] dota_workshop_fileselected")
    DeepPrintTable(data)
end


function GameMode:On_dota_workshop_filecanceled(data)
    print("[BAREBONES] dota_workshop_filecanceled")
    DeepPrintTable(data)
end


function GameMode:On_rich_presence_updated(data)
    print("[BAREBONES] rich_presence_updated")
    DeepPrintTable(data)
end


function GameMode:On_dota_hero_random(data)
    print("[BAREBONES] dota_hero_random")
    DeepPrintTable(data)
end


function GameMode:On_dota_rd_chat_turn(data)
    print("[BAREBONES] dota_rd_chat_turn")
    DeepPrintTable(data)
end


function GameMode:On_dota_favorite_heroes_updated(data)
    print("[BAREBONES] dota_favorite_heroes_updated")
    DeepPrintTable(data)
end


function GameMode:On_profile_closed(data)
    print("[BAREBONES] profile_closed")
    DeepPrintTable(data)
end


function GameMode:On_item_preview_closed(data)
    print("[BAREBONES] item_preview_closed")
    DeepPrintTable(data)
end


function GameMode:On_dashboard_switched_section(data)
    print("[BAREBONES] dashboard_switched_section")
    DeepPrintTable(data)
end


function GameMode:On_dota_tournament_item_event(data)
    print("[BAREBONES] dota_tournament_item_event")
    DeepPrintTable(data)
end


function GameMode:On_dota_hero_swap(data)
    print("[BAREBONES] dota_hero_swap")
    DeepPrintTable(data)
end


function GameMode:On_dota_reset_suggested_items(data)
    print("[BAREBONES] dota_reset_suggested_items")
    DeepPrintTable(data)
end


function GameMode:On_halloween_high_score_received(data)
    print("[BAREBONES] halloween_high_score_received")
    DeepPrintTable(data)
end


function GameMode:On_halloween_phase_end(data)
    print("[BAREBONES] halloween_phase_end")
    DeepPrintTable(data)
end


function GameMode:On_halloween_high_score_request_failed(data)
    print("[BAREBONES] halloween_high_score_request_failed")
    DeepPrintTable(data)
end


function GameMode:On_dota_hud_skin_changed(data)
    print("[BAREBONES] dota_hud_skin_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_inventory_player_got_item(data)
    print("[BAREBONES] dota_inventory_player_got_item")
    DeepPrintTable(data)
end


function GameMode:On_player_is_experienced(data)
    print("[BAREBONES] player_is_experienced")
    DeepPrintTable(data)
end


function GameMode:On_player_is_notexperienced(data)
    print("[BAREBONES] player_is_notexperienced")
    DeepPrintTable(data)
end


function GameMode:On_dota_tutorial_lesson_start(data)
    print("[BAREBONES] dota_tutorial_lesson_start")
    DeepPrintTable(data)
end


function GameMode:On_map_location_updated(data)
    print("[BAREBONES] map_location_updated")
    DeepPrintTable(data)
end


function GameMode:On_richpresence_custom_updated(data)
    print("[BAREBONES] richpresence_custom_updated")
    DeepPrintTable(data)
end


function GameMode:On_game_end_visible(data)
    print("[BAREBONES] game_end_visible")
    DeepPrintTable(data)
end


function GameMode:On_antiaddiction_update(data)
    print("[BAREBONES] antiaddiction_update")
    DeepPrintTable(data)
end


function GameMode:On_highlight_hud_element(data)
    print("[BAREBONES] highlight_hud_element")
    DeepPrintTable(data)
end


function GameMode:On_hide_highlight_hud_element(data)
    print("[BAREBONES] hide_highlight_hud_element")
    DeepPrintTable(data)
end


function GameMode:On_intro_video_finished(data)
    print("[BAREBONES] intro_video_finished")
    DeepPrintTable(data)
end


function GameMode:On_matchmaking_status_visibility_changed(data)
    print("[BAREBONES] matchmaking_status_visibility_changed")
    DeepPrintTable(data)
end


function GameMode:On_practice_lobby_visibility_changed(data)
    print("[BAREBONES] practice_lobby_visibility_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_courier_transfer_item(data)
    print("[BAREBONES] dota_courier_transfer_item")
    DeepPrintTable(data)
end


function GameMode:On_full_ui_unlocked(data)
    print("[BAREBONES] full_ui_unlocked")
    DeepPrintTable(data)
end


function GameMode:On_client_connectionless_packet(data)
    print("[BAREBONES] client_connectionless_packet")
    DeepPrintTable(data)
end


function GameMode:On_hero_selector_preview_set(data)
    print("[BAREBONES] hero_selector_preview_set")
    DeepPrintTable(data)
end


function GameMode:On_antiaddiction_toast(data)
    print("[BAREBONES] antiaddiction_toast")
    DeepPrintTable(data)
end


function GameMode:On_hero_picker_shown(data)
    print("[BAREBONES] hero_picker_shown")
    DeepPrintTable(data)
end


function GameMode:On_hero_picker_hidden(data)
    print("[BAREBONES] hero_picker_hidden")
    DeepPrintTable(data)
end


function GameMode:On_dota_local_quickbuy_changed(data)
    print("[BAREBONES] dota_local_quickbuy_changed")
    DeepPrintTable(data)
end


function GameMode:On_show_center_message(data)
    print("[BAREBONES] show_center_message")
    DeepPrintTable(data)
end


function GameMode:On_hud_flip_changed(data)
    print("[BAREBONES] hud_flip_changed")
    DeepPrintTable(data)
end


function GameMode:On_frosty_points_updated(data)
    print("[BAREBONES] frosty_points_updated")
    DeepPrintTable(data)
end


function GameMode:On_defeated(data)
    print("[BAREBONES] defeated")
    DeepPrintTable(data)
end


function GameMode:On_reset_defeated(data)
    print("[BAREBONES] reset_defeated")
    DeepPrintTable(data)
end


function GameMode:On_booster_state_updated(data)
    print("[BAREBONES] booster_state_updated")
    DeepPrintTable(data)
end


function GameMode:On_event_points_updated(data)
    print("[BAREBONES] event_points_updated")
    DeepPrintTable(data)
end


function GameMode:On_local_player_event_points(data)
    print("[BAREBONES] local_player_event_points")
    DeepPrintTable(data)
end


function GameMode:On_custom_game_difficulty(data)
    print("[BAREBONES] custom_game_difficulty")
    DeepPrintTable(data)
end


function GameMode:On_tree_cut(data)
    print("[BAREBONES] tree_cut")
    DeepPrintTable(data)
end


function GameMode:On_ugc_details_arrived(data)
    print("[BAREBONES] ugc_details_arrived")
    DeepPrintTable(data)
end


function GameMode:On_ugc_subscribed(data)
    print("[BAREBONES] ugc_subscribed")
    DeepPrintTable(data)
end


function GameMode:On_ugc_unsubscribed(data)
    print("[BAREBONES] ugc_unsubscribed")
    DeepPrintTable(data)
end


function GameMode:On_prizepool_received(data)
    print("[BAREBONES] prizepool_received")
    DeepPrintTable(data)
end


function GameMode:On_microtransaction_success(data)
    print("[BAREBONES] microtransaction_success")
    DeepPrintTable(data)
end


function GameMode:On_dota_rubick_ability_steal(data)
    print("[BAREBONES] dota_rubick_ability_steal")
    DeepPrintTable(data)
end


function GameMode:On_compendium_event_actions_loaded(data)
    print("[BAREBONES] compendium_event_actions_loaded")
    DeepPrintTable(data)
end


function GameMode:On_compendium_selections_loaded(data)
    print("[BAREBONES] compendium_selections_loaded")
    DeepPrintTable(data)
end


function GameMode:On_compendium_set_selection_failed(data)
    print("[BAREBONES] compendium_set_selection_failed")
    DeepPrintTable(data)
end

function GameMode:On_community_cached_names_updated(data)
    print("[BAREBONES] community_cached_names_updated")
    DeepPrintTable(data)
end

function GameMode:On_dota_team_kill_credit(data)
    print("[BAREBONES] dota_team_kill_credit")
    DeepPrintTable(data)
end

function GameMode:On_dota_effigy_kill(data)
    print("[BAREBONES] dota_effigy_kill")
    DeepPrintTable(data)
end

function GameMode:On_dota_chat_assassin_announce(data)
    print("[BAREBONES] dota_chat_assassin_announce")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_assassin_denied(data)
    print("[BAREBONES] dota_chat_assassin_denied")
    DeepPrintTable(data)
end


function GameMode:On_dota_chat_assassin_success(data)
    print("[BAREBONES] dota_chat_assassin_success")
    DeepPrintTable(data)
end


function GameMode:On_player_info_individual_updated(data)
    print("[BAREBONES] player_info_individual_updated")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_begin_cast(data)
    print("[BAREBONES] dota_player_begin_cast")
    DeepPrintTable(data)
end


function GameMode:On_dota_non_player_begin_cast(data)
    print("[BAREBONES] dota_non_player_begin_cast")
    DeepPrintTable(data)
end


function GameMode:On_dota_item_combined(data)
    print("[BAREBONES] dota_item_combined")
    DeepPrintTable(data)
end


function GameMode:On_profile_opened(data)
    print("[BAREBONES] profile_opened")
    DeepPrintTable(data)
end


function GameMode:On_dota_tutorial_task_advance(data)
    print("[BAREBONES] dota_tutorial_task_advance")
    DeepPrintTable(data)
end


function GameMode:On_dota_tutorial_shop_toggled(data)
    print("[BAREBONES] dota_tutorial_shop_toggled")
    DeepPrintTable(data)
end


function GameMode:On_ugc_download_requested(data)
    print("[BAREBONES] ugc_download_requested")
    DeepPrintTable(data)
end


function GameMode:On_ugc_installed(data)
    print("[BAREBONES] ugc_installed")
    DeepPrintTable(data)
end


function GameMode:On_compendium_trophies_loaded(data)
    print("[BAREBONES] compendium_trophies_loaded")
    DeepPrintTable(data)
end


function GameMode:On_spec_item_pickup(data)
    print("[BAREBONES] spec_item_pickup")
    DeepPrintTable(data)
end


function GameMode:On_spec_aegis_reclaim_time(data)
    print("[BAREBONES] spec_aegis_reclaim_time")
    DeepPrintTable(data)
end


function GameMode:On_account_trophies_changed(data)
    print("[BAREBONES] account_trophies_changed")
    DeepPrintTable(data)
end


function GameMode:On_account_all_hero_challenge_changed(data)
    print("[BAREBONES] account_all_hero_challenge_changed")
    DeepPrintTable(data)
end


function GameMode:On_team_showcase_ui_update(data)
    print("[BAREBONES] team_showcase_ui_update")
    DeepPrintTable(data)
end


function GameMode:On_ingame_events_changed(data)
    print("[BAREBONES] ingame_events_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_match_signout(data)
    print("[BAREBONES] dota_match_signout")
    DeepPrintTable(data)
end


function GameMode:On_dota_illusions_created(data)
    print("[BAREBONES] dota_illusions_created")
    DeepPrintTable(data)
end


function GameMode:On_dota_year_beast_killed(data)
    print("[BAREBONES] dota_year_beast_killed")
    DeepPrintTable(data)
end


function GameMode:On_dota_hero_undoselection(data)
    print("[BAREBONES] dota_hero_undoselection")
    DeepPrintTable(data)
end


function GameMode:On_dota_challenge_socache_updated(data)
    print("[BAREBONES] dota_challenge_socache_updated")
    DeepPrintTable(data)
end


function GameMode:On_party_invites_updated(data)
    print("[BAREBONES] party_invites_updated")
    DeepPrintTable(data)
end


function GameMode:On_lobby_invites_updated(data)
    print("[BAREBONES] lobby_invites_updated")
    DeepPrintTable(data)
end


function GameMode:On_custom_game_mode_list_updated(data)
    print("[BAREBONES] custom_game_mode_list_updated")
    DeepPrintTable(data)
end


function GameMode:On_custom_game_lobby_list_updated(data)
    print("[BAREBONES] custom_game_lobby_list_updated")
    DeepPrintTable(data)
end


function GameMode:On_friend_lobby_list_updated(data)
    print("[BAREBONES] friend_lobby_list_updated")
    DeepPrintTable(data)
end


function GameMode:On_dota_team_player_list_changed(data)
    print("[BAREBONES] dota_team_player_list_changed")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_details_changed(data)
    print("[BAREBONES] dota_player_details_changed")
    DeepPrintTable(data)
end


function GameMode:On_player_profile_stats_updated(data)
    print("[BAREBONES] player_profile_stats_updated")
    DeepPrintTable(data)
end


function GameMode:On_custom_game_player_count_updated(data)
    print("[BAREBONES] custom_game_player_count_updated")
    DeepPrintTable(data)
end


function GameMode:On_custom_game_friends_played_updated(data)
    print("[BAREBONES] custom_game_friends_played_updated")
    DeepPrintTable(data)
end


function GameMode:On_custom_games_friends_play_updated(data)
    print("[BAREBONES] custom_games_friends_play_updated")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_update_assigned_hero(data)
    print("[BAREBONES] dota_player_update_assigned_hero")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_hero_selection_dirty(data)
    print("[BAREBONES] dota_player_hero_selection_dirty")
    DeepPrintTable(data)
end


function GameMode:On_dota_npc_goal_reached(data)
    print("[BAREBONES] dota_npc_goal_reached")
    DeepPrintTable(data)
end


function GameMode:On_dota_player_selected_custom_team(data)
    print("[BAREBONES] dota_player_selected_custom_team")
    DeepPrintTable(data)
end

GameMode:StartEventTest()