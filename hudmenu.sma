#include <amxmodx>
#include <fvault>
#include <speedometer>
#include <timer>
#include <strafe_stats>
#include <timer_medals>
#include <spec_list>

#define PLUGIN "Hud menu"
#define VERSION "1.0"
#define AUTHOR "MrShark45 & ftl~"

new const g_szVault[] = "hud_settings";

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /hud", "hud_menu");
}

public plugin_natives(){
	register_library("hud");

	register_native("open_hud_menu", "native_open_hud_menu");
}

public native_open_hud_menu(NumParams){
	new id = get_param(1);
	hud_menu(id);
}

public client_putinserver(id){
	set_task(1.0, "LoadSettings", id);
}

public hud_menu(id){
	new menu = menu_create("\r[FWO] \d- \wHud Menu:", "hud_menu_handler");

	new szItem[64];

	formatex(szItem, charsmax(szItem), "\wSpeed %s", get_bool_speed(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wFps %s", get_bool_fps(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wKeys %s", get_bool_keys(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wTimer %s", get_bool_timer(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wMedals %s", get_bool_medals(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wSpeclist %s", get_bool_speclist(id) ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem);

	formatex(szItem, charsmax(szItem), "\wStats & Pre Settings");
	menu_additem(menu, szItem);


	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public hud_menu_handler(id, menu, item){
	if (item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	switch(item){
		case 0: toggle_speed(id);
		case 1: toggle_fps(id);
		case 2: toggle_keys(id);
		case 3: toggle_timer(id);
		case 4: toggle_medals(id);
		case 5: toggle_speclist(id);
		case 6:{
			menu_destroy(menu);
			open_stats_menu(id);
			return PLUGIN_HANDLED;
		}
	}

	SaveSettings(id);

	menu_destroy(menu);
	hud_menu(id);
	return PLUGIN_HANDLED;
}

public SaveSettings(id){
	if (!is_user_connected(id) || is_user_bot(id)) return;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	new szData[64];
	formatex(szData, charsmax(szData), "%d#%d#%d#%d#%d#%d",
		get_bool_speed(id),
		get_bool_fps(id),
		get_bool_keys(id),
		get_bool_timer(id),
		get_bool_medals(id),
		get_bool_speclist(id)
	);

	fvault_set_data(g_szVault, szName, szData);
}

public LoadSettings(id){
	if (!is_user_connected(id) || is_user_bot(id)) return;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	new szData[64];
	if (fvault_get_data(g_szVault, szName, szData, charsmax(szData))){
		new values[6][8];
		explode_string(szData, "#", values, sizeof(values), sizeof(values[]));

		if(!str_to_num(values[0])) toggle_speed(id);
		if(!str_to_num(values[1])) toggle_fps(id);
		if(str_to_num(values[2])) toggle_keys(id);
		if(!str_to_num(values[3])) toggle_timer(id);
		if(!str_to_num(values[4])) toggle_medals(id);
		if(!str_to_num(values[5])) toggle_speclist(id);
	}
}