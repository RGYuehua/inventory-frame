CMD:pick(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 99999)
    {
        new
            choice[15],
            iTargetID,
            iModelID,
            iValue;
        if(sscanf(params,"s[15]udd", choice, iTargetID, iModelID, iValue))
        {
            SendClientMessageEx(playerid, COLOR_GRAD2, "LUA CHON: set, give, remove.");
            SendClientMessageEx(playerid, COLOR_GRAD2, "SU DUNG: /pick [lua chon] [doi tuong] [id vat pham] [tham so cuoi]");
            return 1;
        }
        if(strcmp(choice,"set", true) == 0)
        {
            if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Nguoi choi chua ket noi!");
            if(iModelID < 0 || iModelID >= MAX_ITEM_MODELID) return SendClientMessageEx(playerid, COLOR_GRAD3, "Invalid code!");
            new max_amount = GetItemMaxAmount(iModelID);
            if(iValue < 0 || iValue > max_amount) return SendClientMessageEx(playerid, COLOR_GRAD3, "Invalid value! (dao dong tu 0 - max so huu).");
            new attribute = GetItemAttribute(iModelID);
            new Float:weight = GetItemWeight(iModelID);
            AddItemInventory(iTargetID, GetSlotInventoryFree(iTargetID), iModelID, iValue, attribute, weight, max_amount);
            new string[256];
            format(string, sizeof(string), "[PICK] %s da set cho %s (%s) vat pham %s (ID: %d - so luong: %d).", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID), GetPlayerIpEx(iTargetID), GTA_Item[iModelID], iModelID, iValue);
            ABroadCast(COLOR_YELLOW, string, 2);
            Log("logs/inventory/admingive.log", string);
        }
    }
    return 1;
}
