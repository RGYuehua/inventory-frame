/*
                        (created by Revolution Gaming Vietnam)
                                Inventory System
                            System by Yue Hua (Luxury)
                        Content: RGAME.VN (2013 - 2025)
                                16.7.2025, GTA:N script
*/

// defines
#define			DIALOG_MENU_INVENTORY			8037
#define			DIALOG_MENU_INVENTORY2			8038

#define 		DIALOG_MENU_SPLIT				8039
#define			DIALOG_MENU_BREAK				8040

// inventory
#define MAX_BACKGROUND_MAIN 2 // background
#define MAX_SLOT_INDEX 36 // slot túi đồ
#define MAX_EQUIPT_SLOT_INDEX 6 // slot trang bị
#define MAX_BACKGROUND_MAIN2_STATS 5 // thông số kỹ thuật hiển thị thông tin dữ kiện người dùng (modelid, clan, old-school ,...)
#define MAX_BACKGROUND_INDEX_STATS 6 // thông số kỹ thuật về vật phẩm (cân nặng ,...)
#define MAX_BUTTON_INVENTORY 4 // số nút bấm inventory
#define MAX_ITEM_MODELID 4

#define INVALID_INVENTORY_INDEX -1

#define REGISTERINVENTORY_THREAD 1
#define CREATEINVENTORY_THREAD 2

// lưu trữ variables inventory
new PlayerText:bg_main[MAX_PLAYERS][MAX_BACKGROUND_MAIN];
new PlayerText:slot_index[MAX_PLAYERS][MAX_SLOT_INDEX];
new PlayerText:equipt_slot_index[MAX_PLAYERS][MAX_EQUIPT_SLOT_INDEX];
new PlayerText:bg_main2_stats[MAX_PLAYERS][MAX_BACKGROUND_MAIN2_STATS];
new PlayerText:bg_index_stats[MAX_PLAYERS][MAX_BACKGROUND_INDEX_STATS];
new PlayerText:btn_inventory[MAX_PLAYERS][MAX_BUTTON_INVENTORY];

new OpenTime[MAX_PLAYERS];

new const GTA_Item[4][] =
{
    "KHO_BAU_RUBY","SACH_VANG","DESERT_EAGLE_CLASSIC","AK47_CLASSIC"
};

new const GTA_ItemDescription[4][] =
{
    "GTA_COLLECTION","CO_THE_DUNG_DE_LAM_NHIEM_VU","SUNG_LUC","SUNG_TRUONG"
};

enum invInfo {
    Float: inv_capacity, // tổng số cân nặng của túi đồ
    inv_slot_lock[MAX_SLOT_INDEX], // khoá slot
    inv_slot_modelid[MAX_SLOT_INDEX], // thông số modelid
    inv_slot_amount[MAX_SLOT_INDEX], // dữ kiện về số lượng khả dụng của vật phẩm
    inv_slot_attribute[MAX_SLOT_INDEX], // dữ kiện về thuộc tính của vật phẩm
    Float:inv_slot_durability[MAX_SLOT_INDEX], // độ bền của vật phẩm
    Float:inv_slot_weight[MAX_SLOT_INDEX], // dữ kiện về khối lượng của vật phẩm
    inv_slot_max_amount[MAX_SLOT_INDEX], // dữ kiện về tổng số lượng người chơi có thể sở hữu của vật phẩm đó
    // equiptment
    Float: inv_equipt_capacity, // tổng số cân nặng của trang bị / 2
    inv_equipt_slot_modelid[MAX_EQUIPT_SLOT_INDEX], // thông số modelid
    inv_equipt_slot_amount[MAX_EQUIPT_SLOT_INDEX], // dữ kiện về số lượng khả dụng của trang bị
    inv_equipt_slot_attribute[MAX_EQUIPT_SLOT_INDEX], // dữ kiện về thuộc tính của vật phẩm
    Float:inv_equipt_slot_durability[MAX_EQUIPT_SLOT_INDEX], // dữ kiện về độ bền của vật phẩm
    Float:inv_equipt_slot_weight[MAX_EQUIPT_SLOT_INDEX], // thông số cân nặng của vật phẩm trang bị
    inv_equipt_slot_max_amount[MAX_EQUIPT_SLOT_INDEX] // thông số về tổng số lượng mà người chơi có thể sở hữu của vật phẩm đó
};
new PlayerInventory[MAX_PLAYERS][invInfo];

// callbacks ,...
hook OnPlayerConnect(playerid) {
    if(!gPlayerLogged{playerid})
    {
        for(new i ; i < MAX_BACKGROUND_MAIN ; i++) {
            bg_main[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new u ; u < MAX_SLOT_INDEX ; u++) {
            slot_index[playerid][u] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new y ; y < MAX_EQUIPT_SLOT_INDEX ; y++) {
            equipt_slot_index[playerid][y] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new t ; t < MAX_BACKGROUND_MAIN2_STATS ; t++) {
            bg_main2_stats[playerid][t] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new r ; r < MAX_BACKGROUND_INDEX_STATS ; r++) {
            bg_index_stats[playerid][r] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new e ; e < MAX_BUTTON_INVENTORY ; e++) {
            btn_inventory[playerid][e] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_MENU_INVENTORY)
    {
        if(response)
        {
            if(listitem == 0)
            {
                new inv_index = GetPVarInt(playerid, "pSelectSlot3");
                if(PlayerInventory[playerid][inv_slot_modelid][inv_index] != INVALID_INVENTORY_INDEX)
                {
                    EquiptItem(playerid, GetEquiptSlotInventoryFree(playerid), inv_index);
                    SetPVarInt(playerid, "pSelectSlot3", 0);
                }
            }
            if(listitem == 1)
            {
                new inv_index = GetPVarInt(playerid, "pSelectSlot3");
                if(PlayerInventory[playerid][inv_slot_modelid][inv_index] != INVALID_INVENTORY_INDEX)
                {
                    if(PlayerInventory[playerid][inv_slot_amount][inv_index] >= 0 && PlayerInventory[playerid][inv_slot_amount][inv_index] <= 2) return SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: So luong qua nho khong the phan tach.");
                    ShowPlayerDialogEx(playerid, DIALOG_MENU_SPLIT, DIALOG_STYLE_INPUT, "Phan tach", "Vui long nhap so luong ban muon phan tach:", "Nhap","");
                }
            }
            if(listitem == 2)
            {
                new inv_index = GetPVarInt(playerid, "pSelectSlot3");
                new string[256];
                format(string, sizeof(string), "Ban co chac muon pha huy vat pham {FF0000}%s?\nSau khi xoa ko the phuc hoi\nHay nhan chap nhan neu ban dong y hoac huy de huy qua trinh nay.", GTA_Item[PlayerInventory[playerid][inv_slot_modelid][inv_index]]);
                ShowPlayerDialogEx(playerid, DIALOG_MENU_BREAK, DIALOG_STYLE_MSGBOX, "Pha huy", string, "Chap nhan","Huy");
            }
        }
        else
        {
            SelectTextDraw(playerid, 0xFF0000FF);
        }
    }
    if(dialogid == DIALOG_MENU_INVENTORY2)
    {
        if(response)
        {
            if(listitem == 0)
            {
                new inv_index = GetPVarInt(playerid, "pSelectSlot3");
                if(PlayerInventory[playerid][inv_equipt_slot_modelid][inv_index] != INVALID_INVENTORY_INDEX)
                {
                    UnEquiptItem(playerid, GetSlotInventoryFree(playerid), inv_index);
                    SetPVarInt(playerid, "pSelectSlot3", 0);
                }
            }
        }
        else
        {
            SelectTextDraw(playerid, 0xFF0000FF);
        }
    }
    if(dialogid == DIALOG_MENU_SPLIT)
    {
        if(response)
        {
            new inv_index = GetPVarInt(playerid, "pSelectSlot3");
            if(!IsNumeric(inputtext)) {
                SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Loi xay ra trong qua trinh phan tach.");
                SetPVarInt(playerid, "pSelectSlot3", 0);
                return 1;
            }
            if(strval(inputtext) < 3 || strval(inputtext) > PlayerInventory[playerid][inv_slot_amount][inv_index])
            {
                SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Du lieu phan tach vuot ngoai so luong kha dung.");
                SetPVarInt(playerid, "pSelectSlot3", 0);
                return 1;
            }
            SplitItem(playerid, inv_index, strval(inputtext));
            SetPVarInt(playerid, "pSelectSlot3", 0);

        }
        else
        {
            SelectTextDraw(playerid, 0xFF0000FF);
        }
    }
    if(dialogid == DIALOG_MENU_BREAK)
    {
        if(response)
        {
            new inv_index = GetPVarInt(playerid, "pSelectSlot3");
            BreakItem(playerid, inv_index);
            SetPVarInt(playerid, "pSelectSlot3", 0);
        }
        else
        {
            SelectTextDraw(playerid, 0xFF0000FF);
        }
    }
    return 1;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
    // inventory
	if(playertextid == btn_inventory[playerid][0])
	{
		DestroyPTDInventory(playerid);
		SetFrozenInventory(playerid);
		SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Ban da dong thung do...");
	}
	if(playertextid == btn_inventory[playerid][1])
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Chuc nang nay se som duoc ra mat...");
	}
	if(playertextid == btn_inventory[playerid][2])
	{
		if(GetPVarInt(playerid, "pOpenBGMain2") == 0)
		{
			LoadBGMain(playerid, 0);
			SetPVarInt(playerid, "pOpenBGMain2", 1);
		}
		else {
			LoadBGMain(playerid, 1);
			ResetBGIndex(playerid, 1);
			SetPVarInt(playerid, "pOpenBGMain2", 0);
		}
	}
	for(new index ; index < MAX_SLOT_INDEX ; index++)
	{
		if(playertextid == slot_index[playerid][index])
		{
			if(GetPVarInt(playerid, "pClickNumber") == 2)
			{
				SetPVarInt(playerid, "pClickNumber", 0);
			}
			SetPVarInt(playerid, "pSelectSlot", 1); // select slot túi đồ
			SetPVarInt(playerid, "pSelectSlot2", index); // select slot được lựa chọn
			SetPVarInt(playerid, "pClickNumber", GetPVarInt(playerid, "pClickNumber") + 1);
			ResetBGIndex(playerid, 0);
		}
	}
	for(new zindex ; zindex < MAX_EQUIPT_SLOT_INDEX ; zindex++)
	{
		if(playertextid == equipt_slot_index[playerid][zindex])
		{
			if(GetPVarInt(playerid, "pClickNumber") == 2)
			{
				SetPVarInt(playerid, "pClickNumber", 0);
			}
			SetPVarInt(playerid, "pSelectSlot", 2); // select slot túi đồ
			SetPVarInt(playerid, "pSelectSlot2", zindex); // select slot được lựa chọn
			SetPVarInt(playerid, "pClickNumber", GetPVarInt(playerid, "pClickNumber") + 1);
			ResetBGIndex(playerid, 0);
		}
	}
    return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if((newkeys & KEY_CTRL_BACK) && gPlayerLogged{playerid})
    {
        if(PlayerInfo[playerid][pInventory] < 1)
        {
            new query[128];
            mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO `inventory` (`sqlId`) VALUES (%d)", GetPlayerSQLId(playerid));
            mysql_tquery(MainPipeline, query, "OnQueryInventory", "ii", REGISTERINVENTORY_THREAD, playerid);
        }
        else
        {
            ShowPlayerInventory(playerid);
        }
    }
    return 1;
}

// function
forward OnQueryInventory(resultid, extraid);
public OnQueryInventory(resultid, extraid)
{
    switch(resultid)
    {
        case REGISTERINVENTORY_THREAD:
        {
            PlayerInfo[extraid][pInventory] = 1;
            // thiết lập dữ liệu cho inventory
            PlayerInventory[extraid][inv_capacity] = 40.0; // 40 kg dành cho người mới
            PlayerInventory[extraid][inv_equipt_capacity] = PlayerInventory[extraid][inv_capacity] / 2; // tổng cân nặng túi đồ chia cho 2
            // cài đặt vòng lặp
            for(new index ; index < MAX_SLOT_INDEX ; index++)
            {
                PlayerInventory[extraid][inv_slot_lock][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_modelid][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_amount][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_attribute][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_durability][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_weight][index] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_slot_max_amount][index] = INVALID_INVENTORY_INDEX;
            }

            for(new zindex ; zindex < MAX_EQUIPT_SLOT_INDEX ; zindex++)
            {
                PlayerInventory[extraid][inv_equipt_slot_modelid][zindex] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_equipt_slot_amount][zindex] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_equipt_slot_attribute][zindex] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_equipt_slot_durability][zindex] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_equipt_slot_weight][zindex] = INVALID_INVENTORY_INDEX;
                PlayerInventory[extraid][inv_equipt_slot_max_amount][zindex] = INVALID_INVENTORY_INDEX;
            }

            for(new gindex ; gindex < 16 ; gindex++)
            {
                PlayerInventory[extraid][inv_slot_lock][gindex] = 1; // slot hợp lệ
            }

            printf("[inv] %s da mo tui do lan dau tien.", GetPlayerNameEx(extraid));
            g_mysql_SaveAccount(extraid);

            ShowPlayerInventory(extraid);
        }
        case CREATEINVENTORY_THREAD:
        {
            CreatePTDInventory(extraid);
            ShowPTDInventory(extraid);
            SetFrozenInventory(extraid);

            new item[24];
            for(new i ; i < MAX_SLOT_INDEX ; i++)
            {
                if(PlayerInventory[extraid][inv_slot_lock][i] == INVALID_INVENTORY_INDEX)
                {
                    PlayerTextDrawSetString(extraid, slot_index[extraid][i], "mdl-2002:slotlock");
                }
                if(PlayerInventory[extraid][inv_slot_lock][i] != INVALID_INVENTORY_INDEX && PlayerInventory[extraid][inv_slot_modelid][i] == INVALID_INVENTORY_INDEX) 
                {
                    PlayerTextDrawSetString(extraid, slot_index[extraid][i], "mdl-2002:slot");
                }
                if(PlayerInventory[extraid][inv_slot_modelid][i] != INVALID_INVENTORY_INDEX)
                {
                    format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[extraid][inv_slot_modelid][i]));
                    PlayerTextDrawSetString(extraid, slot_index[extraid][i], item);
                }
            }
        }
    }
    return 1;
}

forward ShowPlayerInventory(playerid);
public ShowPlayerInventory(playerid)
{
    if(bg_main[playerid][0] == PlayerText:INVALID_TEXT_DRAW)
    {
        if(GetPVarInt(playerid, "pOpenTimer") == 0) 
        {
            OnQueryInventory(CREATEINVENTORY_THREAD, playerid);
            SetPVarInt(playerid, "pOpenTimer", 3);
            OpenTime[playerid] = SetTimerEx("OpenTimer", 1000, true, "i", playerid);
            SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Ban da mo thung do.");
            return 1;
        }
        else {
            SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Ban dang thao tac qua nhanh...");
            return 1;
        }

    }
    return 0;
}

forward OpenTimer(playerid);
public OpenTimer(playerid)
{
    if(GetPVarInt(playerid, "pOpenTimer") > 0) return SetPVarInt(playerid, "pOpenTimer", GetPVarInt(playerid, "pOpenTimer") - 1);
    KillTimer(OpenTime[playerid]);
    return 1;
}

forward SetFrozenInventory(playerid);
public SetFrozenInventory(playerid)
{
    if(GetPVarInt(playerid, "pFrozenInventory") == 0)
    {
        TogglePlayerControllable(playerid, false);
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
        SelectTextDraw(playerid, 0xFF0000FF);
        SetPVarInt(playerid, "pFrozenInventory", 1);
        return 1;
    }
    else
    {
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        CancelSelectTextDraw(playerid);
        SetPVarInt(playerid, "pFrozenInventory", 0);
    }
    return 1;
}

forward LoadBGMain(playerid, frame);
public LoadBGMain(playerid, frame)
{
    // equiptment
    new item[30];
    for(new z ; z < MAX_EQUIPT_SLOT_INDEX ; z++)
    {
        if(PlayerInventory[playerid][inv_equipt_slot_modelid][z] == INVALID_INVENTORY_INDEX) 
        {
            PlayerTextDrawSetString(playerid, equipt_slot_index[playerid][z], "mdl-2002:slot");
        }
        if(PlayerInventory[playerid][inv_equipt_slot_modelid][z] != INVALID_INVENTORY_INDEX)
        {
            format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_equipt_slot_modelid][z]));
            PlayerTextDrawSetString(playerid, equipt_slot_index[playerid][z], item);
        }
    }

    new
        sub1[30],
        sub2[30],
        sub3[30],
        sub4[30];
    new famedrank[30];
    new 
        Float:sumiweight,
        Float:sumieweight;
    famedrank = "thanh_vien";
    sumiweight = 0.0;
    sumieweight = 0.0;
    for(new index ; index < MAX_SLOT_INDEX ; index++)
    {
        if(PlayerInventory[playerid][inv_slot_weight][index] != INVALID_INVENTORY_INDEX)
        {
            sumiweight += PlayerInventory[playerid][inv_slot_weight][index];
        }
    }
    for(new zindex ; zindex < MAX_EQUIPT_SLOT_INDEX ; zindex++)
    {
        if(PlayerInventory[playerid][inv_equipt_slot_weight][zindex] != INVALID_INVENTORY_INDEX)
        {
            sumieweight += PlayerInventory[playerid][inv_equipt_slot_weight][zindex];
        }
    }
    if(PlayerInfo[playerid][pFamed] >= 1)
    {
        famedrank = "old_school";
    }
    format(sub1, sizeof(sub1), "khong");
    format(sub2, sizeof(sub2), "%s", famedrank);
    format(sub3, sizeof(sub3), "%.2f/%.2f", sumiweight, PlayerInventory[playerid][inv_capacity]);
    format(sub4, sizeof(sub4), "%.2f/%.2f", sumieweight, PlayerInventory[playerid][inv_equipt_capacity]);
    PlayerTextDrawSetString(playerid, bg_main2_stats[playerid][0], sub1);
    PlayerTextDrawSetString(playerid, bg_main2_stats[playerid][1], sub2);
    PlayerTextDrawSetString(playerid, bg_main2_stats[playerid][2], sub3);
    PlayerTextDrawSetString(playerid, bg_main2_stats[playerid][3], sub4);
    switch(frame)
    {
        case 0:
        {
            PlayerTextDrawShow(playerid, bg_main[playerid][1]);
            for(new i ; i < MAX_EQUIPT_SLOT_INDEX ; i++)
            {
                PlayerTextDrawShow(playerid, equipt_slot_index[playerid][i]);
            }
            for(new u ; u < MAX_BACKGROUND_MAIN2_STATS ; u++)
            {
                PlayerTextDrawShow(playerid, bg_main2_stats[playerid][u]);
            }
        }
        case 1:
        {
            PlayerTextDrawHide(playerid, bg_main[playerid][1]);
            for(new y ; y < MAX_EQUIPT_SLOT_INDEX ; y++)
            {
                PlayerTextDrawHide(playerid, equipt_slot_index[playerid][y]);
            }
            for(new t ; t < MAX_BACKGROUND_MAIN2_STATS ; t++)
            {
                PlayerTextDrawHide(playerid, bg_main2_stats[playerid][t]);
            }
        }
    }
    return 1;
}

forward ResetBGIndex(playerid, frame);
public ResetBGIndex(playerid, frame)
{
    new
        item[30],
        amount[30],
        attribute[30],
        weight[30],
        description[30];
    new amountname[24];
    new index = GetPVarInt(playerid, "pSelectSlot2");
    switch(frame)
    {
        case 0:
        {
            if(GetPVarInt(playerid, "pSelectSlot") == 1)
            {
                if(PlayerInventory[playerid][inv_slot_modelid][index] == INVALID_INVENTORY_INDEX || PlayerInventory[playerid][inv_slot_lock][index] == INVALID_INVENTORY_INDEX)
                {
                    if(GetPVarInt(playerid, "pTransfenderSlot") == 1)
                    {
                        TransfenderSlot(playerid, index, GetPVarInt(playerid, "pSelectSlot3"));
                        SetPVarInt(playerid, "pSelectSlot3", 0);
                        SetPVarInt(playerid, "pTransfenderSlot", 0);
                    }
                    return 1;
                }
                if(PlayerInventory[playerid][inv_slot_modelid][index] != INVALID_INVENTORY_INDEX && GetPVarInt(playerid, "pClickNumber") == 2)
                {
                    if(index == GetPVarInt(playerid, "pSelectSlot3"))
                    {
                        ShowPlayerDialogEx(playerid, DIALOG_MENU_INVENTORY, DIALOG_STYLE_LIST, "Thao tac {FF0000}tuy chon", "Gan\nPhan tach\nPha huy", "Chon","Huy");
                    }
                    ResetBGIndex(playerid, 1);
                    SetPVarInt(playerid, "pClickNumber", 0);
                    return 1;
                }
                if(PlayerInventory[playerid][inv_slot_modelid][index] != INVALID_INVENTORY_INDEX && GetPVarInt(playerid, "pClickNumber") == 1)
                {

                    switch(PlayerInventory[playerid][inv_slot_modelid][index])
                    {
                        case 0..1: amountname = "SO_LUONG";
                        case 2..3: amountname = "SO_DAN";
                    }

                    format(item, sizeof(item), "VAT_PHAM_%s", GTA_Item[PlayerInventory[playerid][inv_slot_modelid][index]]);
                    format(amount, sizeof(amount), "%s:_%d/%d", amountname, PlayerInventory[playerid][inv_slot_amount][index], PlayerInventory[playerid][inv_slot_max_amount][index]);
                    format(attribute, sizeof(attribute), "THUOC_TINH:_%d", PlayerInventory[playerid][inv_slot_attribute][index]);
                    format(weight, sizeof(weight), "TRONG_LUONG:_%.3f", PlayerInventory[playerid][inv_slot_weight][index]);
                    format(description, sizeof(description), "%s", GTA_ItemDescription[PlayerInventory[playerid][inv_slot_modelid][index]]);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][1], item);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][2], amount);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][3], attribute);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][4], weight);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][5], description);

                    SetPVarInt(playerid, "pSelectSlot3", index); // slot này có vật phẩm
                    SetPVarInt(playerid, "pTransfenderSlot", 1); // active trạng thái sẵn sàng transfender

                    for(new a ; a < MAX_BACKGROUND_INDEX_STATS ; a++) {
                        PlayerTextDrawShow(playerid, bg_index_stats[playerid][a]);
                    }
                    return 1;
                }

            }
            if(GetPVarInt(playerid, "pSelectSlot") == 2)
            {
                if(PlayerInventory[playerid][inv_equipt_slot_modelid][index] == INVALID_INVENTORY_INDEX)
                {
                    if(GetPVarInt(playerid, "pTransfenderSlot") == 1)
                    {
                        TransfenderSlot(playerid, index, GetPVarInt(playerid, "pSelectSlot3"));
                        SetPVarInt(playerid, "pSelectSlot3", 0);
                        SetPVarInt(playerid, "pTransfenderSlot", 0);
                    }
                    return 1;
                }
                if(PlayerInventory[playerid][inv_equipt_slot_modelid][index] != INVALID_INVENTORY_INDEX && GetPVarInt(playerid, "pClickNumber") == 2)
                {
                    if(index == GetPVarInt(playerid, "pSelectSlot3"))
                    {
                        ShowPlayerDialogEx(playerid, DIALOG_MENU_INVENTORY2, DIALOG_STYLE_LIST, "Thao tac {FF0000}tuy chon", "Go xuong\nGiao dich\nSua chua", "Chon","Huy");
                    }
                    ResetBGIndex(playerid, 1);
                    SetPVarInt(playerid, "pClickNumber", 0);
                    return 1;
                }
                if(PlayerInventory[playerid][inv_equipt_slot_modelid][index] != INVALID_INVENTORY_INDEX && GetPVarInt(playerid, "pClickNumber") == 1)
                {
                    switch(PlayerInventory[playerid][inv_equipt_slot_modelid][index])
                    {
                        case 0..1: amountname = "SO_LUONG";
                        case 2..3: amountname = "SO_DAN";
                    }

                    format(item, sizeof(item), "VAT_PHAM_%s", GTA_Item[PlayerInventory[playerid][inv_equipt_slot_modelid][index]]);
                    format(amount, sizeof(amount), "%s:_%d/%d", amountname, PlayerInventory[playerid][inv_equipt_slot_amount][index], PlayerInventory[playerid][inv_equipt_slot_max_amount][index]);
                    format(attribute, sizeof(attribute), "THUOC_TINH:_%d", PlayerInventory[playerid][inv_equipt_slot_attribute][index]);
                    format(weight, sizeof(weight), "TRONG_LUONG:_%.3f", PlayerInventory[playerid][inv_equipt_slot_weight][index]);
                    format(description, sizeof(description), "%s", GTA_ItemDescription[PlayerInventory[playerid][inv_equipt_slot_modelid][index]]);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][1], item);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][2], amount);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][3], attribute);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][4], weight);
                    PlayerTextDrawSetString(playerid, bg_index_stats[playerid][5], description);

                    SetPVarInt(playerid, "pSelectSlot3", index);
                    SetPVarInt(playerid, "pTransfenderSlot", 1);

                    for(new b ; b < MAX_BACKGROUND_INDEX_STATS ; b++) {
                        PlayerTextDrawShow(playerid, bg_index_stats[playerid][b]);
                    }
                }
            }
        }
        case 1:
        {
            for(new i ; i < MAX_BACKGROUND_INDEX_STATS ; i++)
            {
                PlayerTextDrawHide(playerid, bg_index_stats[playerid][i]);
            }
        }
    }
    return 1;
}

forward AddItemInventory(playerid, index, iModelID, iValue, attribute, Float:weight, max_amount);
public AddItemInventory(playerid, index, iModelID, iValue, attribute, Float:weight, max_amount) {
    if(index != INVALID_INVENTORY_INDEX)
    {
        PlayerInventory[playerid][inv_slot_modelid][index] = iModelID;
        PlayerInventory[playerid][inv_slot_amount][index] = iValue;
        PlayerInventory[playerid][inv_slot_attribute][index] = attribute;
        PlayerInventory[playerid][inv_slot_durability][index] = 1000.0;
        PlayerInventory[playerid][inv_slot_weight][index] = weight;
        PlayerInventory[playerid][inv_slot_max_amount][index] = max_amount;

        new item[30];
        format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_slot_modelid][index]));
        PlayerTextDrawSetString(playerid, slot_index[playerid][index], item);

        SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Mot vat pham da duoc chuyen vao kho do cua ban...");

        return 1;
    }
    return INVALID_INVENTORY_INDEX;
}

forward GetSlotInventoryFree(playerid);
public GetSlotInventoryFree(playerid)
{
    for(new i ; i < MAX_SLOT_INDEX ; i++)
    {
        if(PlayerInventory[playerid][inv_slot_lock][i] != INVALID_INVENTORY_INDEX && PlayerInventory[playerid][inv_slot_modelid][i] == INVALID_INVENTORY_INDEX)
        {
            return i;
        }
    }
    return INVALID_INVENTORY_INDEX;
}

forward GetEquiptSlotInventoryFree(playerid);
public GetEquiptSlotInventoryFree(playerid)
{
    for(new i ; i < MAX_EQUIPT_SLOT_INDEX ; i++)
    {
        if(PlayerInventory[playerid][inv_equipt_slot_modelid][i] == INVALID_INVENTORY_INDEX)
        {
            return i;
        }
    }
    return INVALID_INVENTORY_INDEX;
}

stock getitemmdlname(value)
{
    switch(value)
    {
        case 0: szMiscArray = "mdl-2002:item_ruby";
        case 1: szMiscArray = "mdl-2002:item_quest";
        case 2: szMiscArray = "mdl-2002:item_de";
        case 3: szMiscArray = "mdl-2002:item_ak";
    }
    return szMiscArray;
}

stock GetItemAttribute(modelid)
{
    switch(modelid)
    {
        case 0 .. 1: return 1;
        case 2 .. 3: return 2;
    }
    return 0;
}

stock GetItemMaxAmount(modelid)
{
    switch(modelid)
    {
        case 0 .. 1: return 1;
        case 2: return 29;
        case 3: return 120;
    }
    return 0;
}

stock Float:GetItemWeight(modelid)
{
    switch(modelid)
    {
        case 0: return 5.0;
        case 1: return 0.3;
        case 2: return 4.2;
        case 3: return 9.3;
    }
    return 0.0;
}

stock TransfenderSlot(playerid, newslot, oldslot)
{
    new item[30];
    if(GetPVarInt(playerid, "pSelectSlot") == 1) // click túi đồ
    {
        PlayerInventory[playerid][inv_slot_modelid][newslot] = PlayerInventory[playerid][inv_slot_modelid][oldslot];
        PlayerInventory[playerid][inv_slot_amount][newslot] = PlayerInventory[playerid][inv_slot_amount][oldslot];
        PlayerInventory[playerid][inv_slot_attribute][newslot] = PlayerInventory[playerid][inv_slot_attribute][oldslot];
        PlayerInventory[playerid][inv_slot_durability][newslot] = PlayerInventory[playerid][inv_slot_durability][oldslot];
        PlayerInventory[playerid][inv_slot_weight][newslot] = PlayerInventory[playerid][inv_slot_weight][oldslot];
        PlayerInventory[playerid][inv_slot_max_amount][newslot] = PlayerInventory[playerid][inv_slot_max_amount][oldslot];
        // refesh value old slot
        PlayerInventory[playerid][inv_slot_modelid][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_slot_amount][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_slot_attribute][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_slot_durability][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_slot_weight][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_slot_max_amount][oldslot] = INVALID_INVENTORY_INDEX;

        if(PlayerInventory[playerid][inv_slot_lock][oldslot] != INVALID_INVENTORY_INDEX && PlayerInventory[playerid][inv_slot_modelid][oldslot] == INVALID_INVENTORY_INDEX) 
        {
            PlayerTextDrawSetString(playerid, slot_index[playerid][oldslot], "mdl-2002:slot");
        }
        if(PlayerInventory[playerid][inv_slot_modelid][newslot] != INVALID_INVENTORY_INDEX)
        {
            format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_slot_modelid][newslot]));
            PlayerTextDrawSetString(playerid, slot_index[playerid][newslot], item);
        }

        return 1;
    }
    if(GetPVarInt(playerid, "pSelectSlot") == 2) // click slot trang bị
    {
        PlayerInventory[playerid][inv_equipt_slot_modelid][newslot] = PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot];
        PlayerInventory[playerid][inv_equipt_slot_amount][newslot] = PlayerInventory[playerid][inv_equipt_slot_amount][oldslot];
        PlayerInventory[playerid][inv_equipt_slot_attribute][newslot] = PlayerInventory[playerid][inv_equipt_slot_attribute][oldslot];
        PlayerInventory[playerid][inv_equipt_slot_durability][newslot] = PlayerInventory[playerid][inv_equipt_slot_durability][oldslot];
        PlayerInventory[playerid][inv_equipt_slot_weight][newslot] = PlayerInventory[playerid][inv_equipt_slot_weight][oldslot];
        PlayerInventory[playerid][inv_equipt_slot_max_amount][newslot] = PlayerInventory[playerid][inv_equipt_slot_max_amount][oldslot];
        // refresh value old slot
        PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_amount][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_attribute][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_durability][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_weight][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_max_amount][oldslot] = INVALID_INVENTORY_INDEX;

        if(PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot] == INVALID_INVENTORY_INDEX) 
        {
            PlayerTextDrawSetString(playerid, equipt_slot_index[playerid][oldslot], "mdl-2002:slot");
        }
        if(PlayerInventory[playerid][inv_equipt_slot_modelid][newslot] != INVALID_INVENTORY_INDEX)
        {
            format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_equipt_slot_modelid][newslot]));
            PlayerTextDrawSetString(playerid, equipt_slot_index[playerid][newslot], item);
        }

        return 1;
    }
    return 0;
}

stock EquiptItem(playerid, newslot, oldslot)
{
    if(newslot != INVALID_INVENTORY_INDEX) {
        if(PlayerInventory[playerid][inv_slot_attribute][oldslot] == 2) {
            PlayerInventory[playerid][inv_equipt_slot_modelid][newslot] = PlayerInventory[playerid][inv_slot_modelid][oldslot];
            PlayerInventory[playerid][inv_equipt_slot_amount][newslot] = PlayerInventory[playerid][inv_slot_amount][oldslot];
            PlayerInventory[playerid][inv_equipt_slot_attribute][newslot] = PlayerInventory[playerid][inv_slot_attribute][oldslot];
            PlayerInventory[playerid][inv_equipt_slot_durability][newslot] = PlayerInventory[playerid][inv_slot_durability][oldslot];
            PlayerInventory[playerid][inv_equipt_slot_weight][newslot] = PlayerInventory[playerid][inv_slot_weight][oldslot];
            PlayerInventory[playerid][inv_equipt_slot_max_amount][newslot] = PlayerInventory[playerid][inv_slot_max_amount][oldslot];
            // refesh value old slot
            PlayerInventory[playerid][inv_slot_modelid][oldslot] = INVALID_INVENTORY_INDEX;
            PlayerInventory[playerid][inv_slot_amount][oldslot] = INVALID_INVENTORY_INDEX;
            PlayerInventory[playerid][inv_slot_attribute][oldslot] = INVALID_INVENTORY_INDEX;
            PlayerInventory[playerid][inv_slot_durability][oldslot] = INVALID_INVENTORY_INDEX;
            PlayerInventory[playerid][inv_slot_weight][oldslot] = INVALID_INVENTORY_INDEX;
            PlayerInventory[playerid][inv_slot_max_amount][oldslot] = INVALID_INVENTORY_INDEX;

            if(PlayerInventory[playerid][inv_slot_lock][oldslot] != INVALID_INVENTORY_INDEX && PlayerInventory[playerid][inv_slot_modelid][oldslot] == INVALID_INVENTORY_INDEX) 
            {
                PlayerTextDrawSetString(playerid, slot_index[playerid][oldslot], "mdl-2002:slot");
            }

            LoadBGMain(playerid, 0);

            SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Da gan vat pham vao trang bi.");

            ApplyTransform(playerid, PlayerInventory[playerid][inv_equipt_slot_modelid][newslot], 0);
            return 1;
        }
        if(PlayerInventory[playerid][inv_slot_attribute][oldslot] == 1) {
            ApplyTransform(playerid, PlayerInventory[playerid][inv_slot_modelid][newslot], oldslot);
            return 1;
        }
    }
    return INVALID_INVENTORY_INDEX;
}

stock UnEquiptItem(playerid, newslot, oldslot)
{
    new item[30];
    if(newslot != INVALID_INVENTORY_INDEX)
    {
        PlayerInventory[playerid][inv_slot_modelid][newslot] = PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot];
        PlayerInventory[playerid][inv_slot_amount][newslot] = PlayerInventory[playerid][inv_equipt_slot_amount][oldslot];
        PlayerInventory[playerid][inv_slot_attribute][newslot] = PlayerInventory[playerid][inv_equipt_slot_attribute][oldslot];
        PlayerInventory[playerid][inv_slot_durability][newslot] = PlayerInventory[playerid][inv_equipt_slot_durability][oldslot];
        PlayerInventory[playerid][inv_slot_weight][newslot] = PlayerInventory[playerid][inv_equipt_slot_weight][oldslot];
        PlayerInventory[playerid][inv_slot_max_amount][newslot] = PlayerInventory[playerid][inv_equipt_slot_max_amount][oldslot];

        // refresh value old slot
        PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_amount][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_attribute][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_durability][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_weight][oldslot] = INVALID_INVENTORY_INDEX;
        PlayerInventory[playerid][inv_equipt_slot_max_amount][oldslot] = INVALID_INVENTORY_INDEX;

        if(PlayerInventory[playerid][inv_equipt_slot_modelid][oldslot] == INVALID_INVENTORY_INDEX) 
        {
            PlayerTextDrawSetString(playerid, equipt_slot_index[playerid][oldslot], "mdl-2002:slot");
        }
        if(PlayerInventory[playerid][inv_slot_modelid][newslot] != INVALID_INVENTORY_INDEX)
        {
            format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_slot_modelid][newslot]));
            PlayerTextDrawSetString(playerid, slot_index[playerid][newslot], item);
        }
        SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Da thao xuong mot trang bi.");
        return 1;
    }
    return INVALID_INVENTORY_INDEX;
}

stock SplitItem(playerid, index, inputtext)
{
    new item[30];
    for(new i ; i < MAX_SLOT_INDEX ; i++)
    {
        if(PlayerInventory[playerid][inv_slot_modelid][i] == PlayerInventory[playerid][inv_slot_modelid][index])
        {
            if(PlayerInventory[playerid][inv_slot_amount][i] + inputtext > PlayerInventory[playerid][inv_slot_max_amount][i])
            {
                new while_slot = GetSlotInventoryFree(playerid);
                if(while_slot != INVALID_INVENTORY_INDEX)
                {
                    PlayerInventory[playerid][inv_slot_modelid][while_slot] = PlayerInventory[playerid][inv_slot_modelid][index];
                    PlayerInventory[playerid][inv_slot_amount][while_slot] = PlayerInventory[playerid][inv_slot_amount][index];
                    PlayerInventory[playerid][inv_slot_attribute][while_slot] = PlayerInventory[playerid][inv_slot_attribute][index];
                    PlayerInventory[playerid][inv_slot_durability][while_slot] = PlayerInventory[playerid][inv_slot_durability][index];
                    PlayerInventory[playerid][inv_slot_weight][while_slot] = PlayerInventory[playerid][inv_slot_weight][index];
                    PlayerInventory[playerid][inv_slot_max_amount][while_slot] = PlayerInventory[playerid][inv_slot_max_amount][index];

                    PlayerInventory[playerid][inv_slot_modelid][index] = INVALID_INVENTORY_INDEX;
                    PlayerInventory[playerid][inv_slot_amount][index] = INVALID_INVENTORY_INDEX;
                    PlayerInventory[playerid][inv_slot_attribute][index] = INVALID_INVENTORY_INDEX;
                    PlayerInventory[playerid][inv_slot_durability][index] = INVALID_INVENTORY_INDEX;
                    PlayerInventory[playerid][inv_slot_weight][index] = INVALID_INVENTORY_INDEX;
                    PlayerInventory[playerid][inv_slot_max_amount][index] = INVALID_INVENTORY_INDEX;

                    if(PlayerInventory[playerid][inv_slot_modelid][index] == INVALID_INVENTORY_INDEX) 
                    {
                        PlayerTextDrawSetString(playerid, slot_index[playerid][index], "mdl-2002:slot");
                    }
                    if(PlayerInventory[playerid][inv_slot_modelid][while_slot] != INVALID_INVENTORY_INDEX)
                    {
                        format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_slot_modelid][while_slot]));
                        PlayerTextDrawSetString(playerid, slot_index[playerid][while_slot], item);
                    }
                    SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Phan tach thanh cong!.");
                    return 1;
                }
            }
            if(PlayerInventory[playerid][inv_slot_amount][i] + inputtext <= PlayerInventory[playerid][inv_slot_max_amount][i])
            {
                PlayerInventory[playerid][inv_slot_amount][i] += inputtext;
                PlayerInventory[playerid][inv_slot_amount][index] -= inputtext;
                if(PlayerInventory[playerid][inv_slot_modelid][index] == INVALID_INVENTORY_INDEX) 
                {
                    PlayerTextDrawSetString(playerid, slot_index[playerid][index], "mdl-2002:slot");
                }
                if(PlayerInventory[playerid][inv_slot_modelid][i] != INVALID_INVENTORY_INDEX)
                {
                    format(item, sizeof(item), "%s", getitemmdlname(PlayerInventory[playerid][inv_slot_modelid][i]));
                    PlayerTextDrawSetString(playerid, slot_index[playerid][i], item);
                }
                SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Phan tach thanh cong!.");
                return 1;
            }
        }
    }
    return INVALID_INVENTORY_INDEX;
}

stock BreakItem(playerid, index)
{
    new string[256];

    format(string, sizeof(string), "[PICK] %s (%s) da pha huy vat pham %s (ID: %d).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GTA_Item[PlayerInventory[playerid][inv_slot_modelid][index]], PlayerInventory[playerid][inv_slot_modelid][index]);
    ABroadCast(COLOR_YELLOW, string, 2);
    Log("logs/inventory/player.log", string);

    PlayerInventory[playerid][inv_slot_modelid][index] = INVALID_INVENTORY_INDEX;
    PlayerInventory[playerid][inv_slot_amount][index] = INVALID_INVENTORY_INDEX;
    PlayerInventory[playerid][inv_slot_attribute][index] = INVALID_INVENTORY_INDEX;
    PlayerInventory[playerid][inv_slot_durability][index] = INVALID_INVENTORY_INDEX;
    PlayerInventory[playerid][inv_slot_weight][index] = INVALID_INVENTORY_INDEX;
    PlayerInventory[playerid][inv_slot_max_amount][index] = INVALID_INVENTORY_INDEX;

    if(PlayerInventory[playerid][inv_slot_modelid][index] == INVALID_INVENTORY_INDEX) 
    {
        PlayerTextDrawSetString(playerid, slot_index[playerid][index], "mdl-2002:slot");
    }

    LoadBGMain(playerid, 0);

    SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Pha huy thanh cong!");
    return 1;
}

stock ApplyTransform(playerid, modelid, index)
{
    if(modelid == 0)
    {
        DestroyPTDInventory(playerid);
        SetFrozenInventory(playerid);
        if(PlayerInventory[playerid][inv_slot_amount][index] >= 1)
        {
            PlayerInfo[playerid][pExpAdventure] += 1500.0;
            SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: Ban da mo hom va nhan duoc 1500.0 EXP phieu luu!");
            RefreshExpAdventure(playerid);
            PlayerInventory[playerid][inv_slot_amount][index]--;
        }
        else {
            SendClientMessageEx(playerid, COLOR_WHITE, "[{FFBC47}TUI DO{FFFFFF}]: khong the su dung duoc nua, xin hay pha huy!");
        }
    }
    if(modelid == 2)
    {
        DestroyPTDInventory(playerid);
        SetFrozenInventory(playerid);
        GivePlayerValidWeapon(playerid, 24);
        ApplyAnimation(playerid,"RIOT","RIOT_FUKU",3.8,0,0,0,0,0,1);
    }
    if(modelid == 3)
    {
        DestroyPTDInventory(playerid);
        SetFrozenInventory(playerid);
        GivePlayerValidWeapon(playerid, 30);
        ApplyAnimation(playerid,"RIOT","RIOT_FUKU",3.8,0,0,0,0,0,1);
    }
    return 1;
}

// TextDraw
forward CreatePTDInventory(playerid);
public CreatePTDInventory(playerid) {

    // Main
    bg_main[playerid][0] = CreatePlayerTextDraw(playerid, 454.000, 112.000, "mdl-2002:bg_main");
    PlayerTextDrawTextSize(playerid, bg_main[playerid][0], 176.000, 293.000);
    PlayerTextDrawAlignment(playerid, bg_main[playerid][0], 1);
    PlayerTextDrawColor(playerid, bg_main[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, bg_main[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, bg_main[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main[playerid][0], 255);
    PlayerTextDrawFont(playerid, bg_main[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, bg_main[playerid][0], 1);

    bg_main[playerid][1] = CreatePlayerTextDraw(playerid, 274.000, 112.000, "mdl-2002:bg_main2");
    PlayerTextDrawTextSize(playerid, bg_main[playerid][1], 176.000, 293.000);
    PlayerTextDrawAlignment(playerid, bg_main[playerid][1], 1);
    PlayerTextDrawColor(playerid, bg_main[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, bg_main[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, bg_main[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main[playerid][1], 255);
    PlayerTextDrawFont(playerid, bg_main[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, bg_main[playerid][1], 1);

    // Button
    btn_inventory[playerid][0] = CreatePlayerTextDraw(playerid, 615.000, 117.000, "mdl-2002:button_close");
    PlayerTextDrawTextSize(playerid, btn_inventory[playerid][0], 11.000, 12.000);
    PlayerTextDrawAlignment(playerid, btn_inventory[playerid][0], 1);
    PlayerTextDrawColor(playerid, btn_inventory[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, btn_inventory[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, btn_inventory[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, btn_inventory[playerid][0], 255);
    PlayerTextDrawFont(playerid, btn_inventory[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, btn_inventory[playerid][0], 1);
    PlayerTextDrawSetSelectable(playerid, btn_inventory[playerid][0], 1);

    btn_inventory[playerid][1] = CreatePlayerTextDraw(playerid, 576.000, 365.000, "mdl-2002:button_fixed");
    PlayerTextDrawTextSize(playerid, btn_inventory[playerid][1], 46.000, 17.000);
    PlayerTextDrawAlignment(playerid, btn_inventory[playerid][1], 1);
    PlayerTextDrawColor(playerid, btn_inventory[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, btn_inventory[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, btn_inventory[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, btn_inventory[playerid][1], 255);
    PlayerTextDrawFont(playerid, btn_inventory[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, btn_inventory[playerid][1], 1);
    PlayerTextDrawSetSelectable(playerid, btn_inventory[playerid][1], 1);

    btn_inventory[playerid][2] = CreatePlayerTextDraw(playerid, 576.000, 384.000, "mdl-2002:button_character");
    PlayerTextDrawTextSize(playerid, btn_inventory[playerid][2], 46.000, 17.000);
    PlayerTextDrawAlignment(playerid, btn_inventory[playerid][2], 1);
    PlayerTextDrawColor(playerid, btn_inventory[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, btn_inventory[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, btn_inventory[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, btn_inventory[playerid][2], 255);
    PlayerTextDrawFont(playerid, btn_inventory[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, btn_inventory[playerid][2], 1);
    PlayerTextDrawSetSelectable(playerid, btn_inventory[playerid][2], 1);

    btn_inventory[playerid][3] = CreatePlayerTextDraw(playerid, 520.000, 337.000, "mdl-2002:button_nextpage");
    PlayerTextDrawTextSize(playerid, btn_inventory[playerid][3], 46.000, 17.000);
    PlayerTextDrawAlignment(playerid, btn_inventory[playerid][3], 1);
    PlayerTextDrawColor(playerid, btn_inventory[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, btn_inventory[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, btn_inventory[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, btn_inventory[playerid][3], 255);
    PlayerTextDrawFont(playerid, btn_inventory[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, btn_inventory[playerid][3], 1);
    PlayerTextDrawSetSelectable(playerid, btn_inventory[playerid][3], 1);

    // slot lock
    slot_index[playerid][0] = CreatePlayerTextDraw(playerid, 462.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][0], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][0], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][0], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][0], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][0], 1);

    slot_index[playerid][1] = CreatePlayerTextDraw(playerid, 489.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][1], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][1], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][1], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][1], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][1], 1);

    slot_index[playerid][2] = CreatePlayerTextDraw(playerid, 516.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][2], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][2], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][2], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][2], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][2], 1);

    slot_index[playerid][3] = CreatePlayerTextDraw(playerid, 543.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][3], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][3], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][3], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][3], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][3], 1);

    slot_index[playerid][4] = CreatePlayerTextDraw(playerid, 570.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][4], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][4], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][4], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][4], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][4], 1);

    slot_index[playerid][5] = CreatePlayerTextDraw(playerid, 597.000, 149.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][5], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][5], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][5], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][5], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][5], 1);

    slot_index[playerid][6] = CreatePlayerTextDraw(playerid, 462.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][6], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][6], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][6], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][6], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][6], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][6], 1);

    slot_index[playerid][7] = CreatePlayerTextDraw(playerid, 489.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][7], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][7], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][7], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][7], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][7], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][7], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][7], 1);

    slot_index[playerid][8] = CreatePlayerTextDraw(playerid, 516.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][8], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][8], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][8], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][8], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][8], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][8], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][8], 1);

    slot_index[playerid][9] = CreatePlayerTextDraw(playerid, 543.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][9], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][9], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][9], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][9], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][9], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][9], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][9], 1);

    slot_index[playerid][10] = CreatePlayerTextDraw(playerid, 570.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][10], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][10], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][10], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][10], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][10], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][10], 1);

    slot_index[playerid][11] = CreatePlayerTextDraw(playerid, 597.000, 180.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][11], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][11], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][11], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][11], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][11], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][11], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][11], 1);

    slot_index[playerid][12] = CreatePlayerTextDraw(playerid, 462.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][12], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][12], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][12], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][12], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][12], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][12], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][12], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][12], 1);

    slot_index[playerid][13] = CreatePlayerTextDraw(playerid, 489.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][13], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][13], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][13], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][13], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][13], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][13], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][13], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][13], 1);

    slot_index[playerid][14] = CreatePlayerTextDraw(playerid, 516.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][14], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][14], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][14], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][14], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][14], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][14], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][14], 1);

    slot_index[playerid][15] = CreatePlayerTextDraw(playerid, 543.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][15], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][15], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][15], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][15], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][15], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][15], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][15], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][15], 1);

    slot_index[playerid][16] = CreatePlayerTextDraw(playerid, 570.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][16], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][16], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][16], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][16], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][16], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][16], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][16], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][16], 1);

    slot_index[playerid][17] = CreatePlayerTextDraw(playerid, 597.000, 211.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][17], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][17], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][17], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][17], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][17], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][17], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][17], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][17], 1);

    slot_index[playerid][18] = CreatePlayerTextDraw(playerid, 462.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][18], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][18], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][18], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][18], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][18], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][18], 1);

    slot_index[playerid][19] = CreatePlayerTextDraw(playerid, 489.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][19], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][19], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][19], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][19], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][19], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][19], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][19], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][19], 1);

    slot_index[playerid][20] = CreatePlayerTextDraw(playerid, 516.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][20], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][20], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][20], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][20], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][20], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][20], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][20], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][20], 1);

    slot_index[playerid][21] = CreatePlayerTextDraw(playerid, 543.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][21], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][21], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][21], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][21], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][21], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][21], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][21], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][21], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][21], 1);

    slot_index[playerid][22] = CreatePlayerTextDraw(playerid, 570.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][22], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][22], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][22], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][22], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][22], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][22], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][22], 1);

    slot_index[playerid][23] = CreatePlayerTextDraw(playerid, 597.000, 242.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][23], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][23], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][23], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][23], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][23], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][23], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][23], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][23], 1);

    slot_index[playerid][24] = CreatePlayerTextDraw(playerid, 462.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][24], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][24], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][24], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][24], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][24], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][24], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][24], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][24], 1);

    slot_index[playerid][25] = CreatePlayerTextDraw(playerid, 489.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][25], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][25], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][25], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][25], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][25], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][25], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][25], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][25], 1);

    slot_index[playerid][26] = CreatePlayerTextDraw(playerid, 516.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][26], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][26], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][26], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][26], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][26], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][26], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][26], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][26], 1);

    slot_index[playerid][27] = CreatePlayerTextDraw(playerid, 543.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][27], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][27], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][27], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][27], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][27], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][27], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][27], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][27], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][27], 1);

    slot_index[playerid][28] = CreatePlayerTextDraw(playerid, 570.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][28], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][28], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][28], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][28], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][28], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][28], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][28], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][28], 1);

    slot_index[playerid][29] = CreatePlayerTextDraw(playerid, 597.000, 273.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][29], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][29], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][29], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][29], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][29], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][29], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][29], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][29], 1);

    slot_index[playerid][30] = CreatePlayerTextDraw(playerid, 462.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][30], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][30], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][30], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][30], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][30], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][30], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][30], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][30], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][30], 1);

    slot_index[playerid][31] = CreatePlayerTextDraw(playerid, 489.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][31], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][31], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][31], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][31], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][31], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][31], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][31], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][31], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][31], 1);

    slot_index[playerid][32] = CreatePlayerTextDraw(playerid, 516.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][32], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][32], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][32], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][32], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][32], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][32], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][32], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][32], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][32], 1);

    slot_index[playerid][33] = CreatePlayerTextDraw(playerid, 543.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][33], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][33], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][33], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][33], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][33], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][33], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][33], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][33], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][33], 1);

    slot_index[playerid][34] = CreatePlayerTextDraw(playerid, 570.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][34], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][34], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][34], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][34], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][34], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][34], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][34], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][34], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][34], 1);

    slot_index[playerid][35] = CreatePlayerTextDraw(playerid, 597.000, 304.000, "mdl-2002:slotlock");
    PlayerTextDrawTextSize(playerid, slot_index[playerid][35], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, slot_index[playerid][35], 1);
    PlayerTextDrawColor(playerid, slot_index[playerid][35], -1);
    PlayerTextDrawSetShadow(playerid, slot_index[playerid][35], 0);
    PlayerTextDrawSetOutline(playerid, slot_index[playerid][35], 0);
    PlayerTextDrawBackgroundColor(playerid, slot_index[playerid][35], 255);
    PlayerTextDrawFont(playerid, slot_index[playerid][35], 4);
    PlayerTextDrawSetProportional(playerid, slot_index[playerid][35], 1);
    PlayerTextDrawSetSelectable(playerid, slot_index[playerid][35], 1);

    // stats
    bg_main2_stats[playerid][0] = CreatePlayerTextDraw(playerid, 312.000, 343.000, "");
    PlayerTextDrawLetterSize(playerid, bg_main2_stats[playerid][0], 0.170, 1.299);
    PlayerTextDrawAlignment(playerid, bg_main2_stats[playerid][0], 2);
    PlayerTextDrawColor(playerid, bg_main2_stats[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, bg_main2_stats[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, bg_main2_stats[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main2_stats[playerid][0], 150);
    PlayerTextDrawFont(playerid, bg_main2_stats[playerid][0], 2);
    PlayerTextDrawSetProportional(playerid, bg_main2_stats[playerid][0], 1);

    bg_main2_stats[playerid][1] = CreatePlayerTextDraw(playerid, 302.000, 363.000, "");
    PlayerTextDrawLetterSize(playerid, bg_main2_stats[playerid][1], 0.170, 1.299);
    PlayerTextDrawAlignment(playerid, bg_main2_stats[playerid][1], 2);
    PlayerTextDrawColor(playerid, bg_main2_stats[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, bg_main2_stats[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, bg_main2_stats[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main2_stats[playerid][1], 150);
    PlayerTextDrawFont(playerid, bg_main2_stats[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, bg_main2_stats[playerid][1], 1);

    bg_main2_stats[playerid][2] = CreatePlayerTextDraw(playerid, 405.000, 343.000, "");
    PlayerTextDrawLetterSize(playerid, bg_main2_stats[playerid][2], 0.170, 1.299);
    PlayerTextDrawAlignment(playerid, bg_main2_stats[playerid][2], 2);
    PlayerTextDrawColor(playerid, bg_main2_stats[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, bg_main2_stats[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, bg_main2_stats[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main2_stats[playerid][2], 150);
    PlayerTextDrawFont(playerid, bg_main2_stats[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, bg_main2_stats[playerid][2], 1);

    bg_main2_stats[playerid][3] = CreatePlayerTextDraw(playerid, 405.000, 363.000, "");
    PlayerTextDrawLetterSize(playerid, bg_main2_stats[playerid][3], 0.170, 1.299);
    PlayerTextDrawAlignment(playerid, bg_main2_stats[playerid][3], 2);
    PlayerTextDrawColor(playerid, bg_main2_stats[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, bg_main2_stats[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, bg_main2_stats[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main2_stats[playerid][3], 150);
    PlayerTextDrawFont(playerid, bg_main2_stats[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, bg_main2_stats[playerid][3], 1);

    bg_main2_stats[playerid][4] = CreatePlayerTextDraw(playerid, 410.000, 294.000, "_");
    PlayerTextDrawTextSize(playerid, bg_main2_stats[playerid][4], 31.000, 25.000);
    PlayerTextDrawAlignment(playerid, bg_main2_stats[playerid][4], 1);
    PlayerTextDrawColor(playerid, bg_main2_stats[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, bg_main2_stats[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, bg_main2_stats[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_main2_stats[playerid][4], 0);
    PlayerTextDrawFont(playerid, bg_main2_stats[playerid][4], 5);
    PlayerTextDrawSetProportional(playerid, bg_main2_stats[playerid][4], 0);
    PlayerTextDrawSetPreviewModel(playerid, bg_main2_stats[playerid][4], GetPlayerSkin(playerid));
    PlayerTextDrawSetPreviewRot(playerid, bg_main2_stats[playerid][4], -18.000, 0.000, 0.000, 1.000);
    PlayerTextDrawSetPreviewVehCol(playerid, bg_main2_stats[playerid][4], 0, 0);

    // equipt slot
    equipt_slot_index[playerid][0] = CreatePlayerTextDraw(playerid, 288.000, 154.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][0], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][0], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][0], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][0], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][0], 1);

    equipt_slot_index[playerid][1] = CreatePlayerTextDraw(playerid, 288.000, 187.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][1], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][1], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][1], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][1], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][1], 1);

    equipt_slot_index[playerid][2] = CreatePlayerTextDraw(playerid, 412.000, 154.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][2], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][2], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][2], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][2], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][2], 1);

    equipt_slot_index[playerid][3] = CreatePlayerTextDraw(playerid, 412.000, 187.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][3], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][3], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][3], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][3], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][3], 1);

    equipt_slot_index[playerid][4] = CreatePlayerTextDraw(playerid, 335.000, 293.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][4], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][4], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][4], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][4], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][4], 1);

    equipt_slot_index[playerid][5] = CreatePlayerTextDraw(playerid, 364.000, 293.000, "mdl-2002:slot");
    PlayerTextDrawTextSize(playerid, equipt_slot_index[playerid][5], 25.000, 30.000);
    PlayerTextDrawAlignment(playerid, equipt_slot_index[playerid][5], 1);
    PlayerTextDrawColor(playerid, equipt_slot_index[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, equipt_slot_index[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, equipt_slot_index[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, equipt_slot_index[playerid][5], 255);
    PlayerTextDrawFont(playerid, equipt_slot_index[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, equipt_slot_index[playerid][5], 1);
    PlayerTextDrawSetSelectable(playerid, equipt_slot_index[playerid][5], 1);

    // item stats
    bg_index_stats[playerid][0] = CreatePlayerTextDraw(playerid, 497.000, -2.000, "mdl-2002:bg_index_stats");
    PlayerTextDrawTextSize(playerid, bg_index_stats[playerid][0], 145.000, 113.000);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][0], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][0], 255);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][0], 1);

    bg_index_stats[playerid][1] = CreatePlayerTextDraw(playerid, 505.000, 28.000, "DAY_LA_HOM_KHO_BAU");
    PlayerTextDrawLetterSize(playerid, bg_index_stats[playerid][1], 0.180, 1.099);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][1], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][1], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][1], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][1], 150);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][1], 1);

    bg_index_stats[playerid][2] = CreatePlayerTextDraw(playerid, 505.000, 40.000, "CON_LAI_03_CAI");
    PlayerTextDrawLetterSize(playerid, bg_index_stats[playerid][2], 0.180, 1.099);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][2], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][2], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][2], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][2], 150);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][2], 1);

    bg_index_stats[playerid][3] = CreatePlayerTextDraw(playerid, 505.000, 52.000, "THUOC_TINH");
    PlayerTextDrawLetterSize(playerid, bg_index_stats[playerid][3], 0.180, 1.099);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][3], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][3], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][3], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][3], 150);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][3], 1);

    bg_index_stats[playerid][4] = CreatePlayerTextDraw(playerid, 505.000, 64.000, "SO_KG:");
    PlayerTextDrawLetterSize(playerid, bg_index_stats[playerid][4], 0.180, 1.099);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][4], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][4], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][4], 150);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][4], 2);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][4], 1);

    bg_index_stats[playerid][5] = CreatePlayerTextDraw(playerid, 505.000, 76.000, "MO_TA:");
    PlayerTextDrawLetterSize(playerid, bg_index_stats[playerid][5], 0.180, 1.099);
    PlayerTextDrawAlignment(playerid, bg_index_stats[playerid][5], 1);
    PlayerTextDrawColor(playerid, bg_index_stats[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, bg_index_stats[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, bg_index_stats[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, bg_index_stats[playerid][5], 150);
    PlayerTextDrawFont(playerid, bg_index_stats[playerid][5], 2);
    PlayerTextDrawSetProportional(playerid, bg_index_stats[playerid][5], 1);

    return 1;
}

forward ShowPTDInventory(playerid);
public ShowPTDInventory(playerid) {
    PlayerTextDrawShow(playerid, bg_main[playerid][0]);
    for(new u ; u < MAX_SLOT_INDEX ; u++) {
        PlayerTextDrawShow(playerid, slot_index[playerid][u]);
    }
    for(new y ; y < MAX_BUTTON_INVENTORY ; y++) {
        PlayerTextDrawShow(playerid, btn_inventory[playerid][y]);
    }
    return 1;
}

forward DestroyPTDInventory(playerid);
public DestroyPTDInventory(playerid) {
    // set invalid textdraw
    for(new i ; i < MAX_BACKGROUND_MAIN ; i++) {
        PlayerTextDrawDestroy(playerid, bg_main[playerid][i]);
        bg_main[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }
    for(new u ; u < MAX_SLOT_INDEX ; u++) {
        PlayerTextDrawDestroy(playerid, slot_index[playerid][u]);
        slot_index[playerid][u] = PlayerText:INVALID_TEXT_DRAW;
    }
    for(new y ; y < MAX_EQUIPT_SLOT_INDEX ; y++) {
        PlayerTextDrawDestroy(playerid, equipt_slot_index[playerid][y]);
        equipt_slot_index[playerid][y] = PlayerText:INVALID_TEXT_DRAW;
    }
    for(new t ; t < MAX_BACKGROUND_MAIN2_STATS ; t++) {
        PlayerTextDrawDestroy(playerid, bg_main2_stats[playerid][t]);
        bg_main2_stats[playerid][t] = PlayerText:INVALID_TEXT_DRAW;
    }
    for(new r ; r < MAX_BACKGROUND_INDEX_STATS ; r++) {
        PlayerTextDrawDestroy(playerid, bg_index_stats[playerid][r]);
        bg_index_stats[playerid][r] = PlayerText:INVALID_TEXT_DRAW;
    }
    for(new e ; e < MAX_BUTTON_INVENTORY ; e++) {
        PlayerTextDrawDestroy(playerid, btn_inventory[playerid][e]);
        btn_inventory[playerid][e] = PlayerText:INVALID_TEXT_DRAW;
    }
    return 1;
}