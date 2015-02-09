#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <DOF2>

#define COR_AZUL    0x1E90FFFF
#define COR_ERRO    0xFF0000FF

#define skSaves	   "skAdmins/%s.ini"
#define skAdmins   7564
#define skRelato   7565
#define skAMenu    7566

#define ADMIN_SPEC_TYPE_NONE 	0
#define ADMIN_SPEC_TYPE_PLAYER 	1
#define ADMIN_SPEC_TYPE_VEHICLE 2

new skAdmin[MAX_PLAYERS];
new Float:X, Float:Y, Float:Z;

public OnFilterScriptInit()
{
	print("\n---------------------------------------");
	print("skAdmin - Admin system - skllx		");
	print("Primeira versão - Básico			");
	print("---------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	DOF2_Exit();
	return 1;
}

public OnPlayerConnect(playerid)
{
	new skFile[50];
	format(skFile, sizeof(skFile), skSaves, skNome(playerid));
	if(DOF2_FileExists(skFile))
	{
		if(DOF2_GetInt(skFile, "Banido") == 1)
		{
		    SendClientMessage(playerid, COR_ERRO, "[skAdmins] Você está banido(a) e não pode ter acesso ao servidor!");
			SetTimerEx("KickP", 500, false, "i", playerid);
			return 1;
		}
		skAdmin[playerid] = DOF2_GetInt(skFile, "Administrador");
		SetPlayerScore(playerid, DOF2_GetInt(skFile, "Pontos")); // De atenção caso seu GM tenha algum sistema que dê pontos/score.
		return 1;
	}else{
		DOF2_CreateFile(skSaves);
		DOF2_SetInt(skFile, "Administrador", 0);
		return 1;
	}
}

public OnPlayerSpawn(playerid)
{
	if(skAdmin[playerid] > 0)
	{
		SetPlayerChatBubble(playerid, "Administrador", 0x1E90FFFF, 20.0, 10000);
	}
	return 1;
}

CMD:daradmin(playerid, params[])
{
    if(skAdmin[playerid] < 2 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, skNivel, skAntes, String[120];
    if(sscanf(params, "id", ID, skNivel)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /DarAdmin [ID] [0-2]");
    if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	if(skNivel < 0 || skAntes > 2) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Nível não existente!");
	skAntes = skAdmin[ID];
    skAdmin[ID] = skNivel;
    if(skNivel > skAntes)
    {
        format(String, sizeof(String), "[skAdmins] Parabéns, você foi promovido(a) à administrador(a) nível {FFFFFF}%d", skAdmin[ID]);
		SendClientMessage(ID, COR_AZUL, String);
		SetPlayerChatBubble(ID, "Administrador", 0x1E90FFFF, 20.0, 10000);
	}else{
        format(String, sizeof(String), "[skAdmins] Você foi rebaixado(a) à administrador(a) nível {FFFFFF}%d", skAdmin[ID]);
		SendClientMessage(ID, COR_ERRO, String);
		SetPlayerChatBubble(ID, " ", 0xFFFFFFAA, 20.0, 10000);
	}
	new skFile[50];
	format(skFile, sizeof(skFile), skSaves, skNome(ID));
	DOF2_SetInt(skFile, "Administrador", skNivel);
	skAdmin[playerid] = skNivel;
	return 1;
}

CMD:fakeban(playerid, params[])
{
    if(skAdmin[playerid] < 2 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, Motivo[80], String[128];
	if(sscanf(params, "ds[80]", ID, Motivo)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /FakeBan [ID] [Motivo]");
	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	format(String, sizeof(String),"[skAdmins] %s baniu o(a) jogador(a) %s [Motivo: %s]", skNome(playerid), skNome(ID), Motivo);
	SendClientMessageToAll(COR_ERRO, String);
	//SendClientMessage(ID, 0xB9BCCCAA, "Server closed the connection.");
	SetTimerEx("KickP", 500, false, "d", ID); // Fica ao interesse do usuário deste FS kickar ou não! :)
	return 1;
}

CMD:fakekick(playerid, params[])
{
    if(skAdmin[playerid] < 2 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, Motivo[80], String[128];
	if(sscanf(params, "ds[80]", ID, Motivo)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /FakeKick [ID] [Motivo]");
	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	format(String, sizeof(String),"[skAdmins] %s kickou o(a) jogador(a) %s [Motivo %s]", skNome(playerid), skNome(ID), Motivo);
	SendClientMessageToAll(COR_ERRO, String);
	SendClientMessage(ID, 0xB9BCCCAA, "Server closed the connection.");
	return 1;
}

CMD:fakechat(playerid, params[])
{
    if(skAdmin[playerid] < 2 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, NomeID[24], String[256], Mensagem[256];
    if(sscanf(params, "ds[256]", ID, Mensagem)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /FakeChat [ID] [Mensagem]");
    if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
    GetPlayerName(ID, NomeID, MAX_PLAYER_NAME);
    format(String, sizeof(String), "{%06x}%s: {FFFFFF}%s", GetPlayerColor(ID) >>> 8, NomeID, Mensagem); // As cores podem bugar.
    SendClientMessageToAll(-1, String);
    return 1;
}

CMD:fakecmd(playerid,params[])
{
    if(skAdmin[playerid] < 2 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, Cmd[256];
    if(sscanf (params, "us[256]", ID, Cmd))
    return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /FakeCmd [ID] [Comando]");
    if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!.");
    CallRemoteFunction("OnPlayerCommandText", "ds", ID, Cmd);
    return 1;
}

CMD:banir(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, Motivo[80], String[128], IP[20];
	if(sscanf(params, "ds[80]s[100]", ID, Motivo)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /Banir [ID] [Motivo]");
	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	if(skAdmin[ID] > skAdmin[playerid])
	{
		SendClientMessage(playerid, COR_ERRO, "[ERRO] Este(a) jogador(a) é superior ao seu nível.");
		format(String, sizeof(String), "[AVISO] O(A) admininistrador(a) %s (%d) tentou te banir.", skNome(playerid), playerid);
		SendClientMessage(ID, COR_ERRO, String);
		return 1;
	}
	format(String, sizeof(String),"[skAdmins] %s baniu o(a) jogador(a) %s [Motivo: %s]", skNome(playerid), skNome(ID), Motivo);
	SendClientMessageToAll(COR_ERRO, String);
	GetPlayerIp(ID, IP, sizeof(IP));
	new skFile[50];
	format(skFile, sizeof(skFile), skSaves, skNome(ID));
	DOF2_SetString(skFile, "Motivo", Motivo);
	DOF2_SetInt(skFile, "Banido", 1);
	DOF2_SaveFile();
	SetTimerEx("BanP", 500, false, "d", ID);
	return 1;
}

CMD:kick(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
    new ID, Motivo[80], String[128];
	if(sscanf(params, "ds[80]s[100]", ID, Motivo)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /Kick [ID] [Motivo]");
	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	if(skAdmin[ID] > skAdmin[playerid])
	{
		SendClientMessage(playerid, COR_ERRO, "[ERRO] Este(a) jogador(a) é superior ao seu nível.");
		format(String, sizeof(String), "[AVISO] O(A) admininistrador(a) %s (%d) tentou te kickar.", skNome(playerid), playerid);
		SendClientMessage(ID, COR_ERRO, String);
		return 1;
	}
	format(String, sizeof(String),"[skAdmins] %s kickou o(a) jogador(a) %s [Motivo: %s]", skNome(playerid), skNome(ID), Motivo);
	SendClientMessageToAll(COR_ERRO, String);
	SetTimerEx("KickP", 500, false, "d", ID);
	return 1;
}

CMD:desarmar(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	if(!strlen(params) || !IsNum(params)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /Desarmar [ID]");
	if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	ResetPlayerWeapons(strval(params));
	new String[50];
	format(String, sizeof(String), "[skAdmins] %s removeu suas armas.", skNome(playerid));
	SendClientMessage(strval(params), COR_ERRO, String);
	SendClientMessage(playerid, -1, "[skAdmins] Armas removidas.");
	return 1;
}

CMD:explodir(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	if(!strlen(params) || !IsNum(params)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /Explodir [ID]");
	if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	GetPlayerPos(strval(params), X, Y, Z);
	CreateExplosion(X, Y, Z, 12, 10.0);
	new String[50];
	format(String, sizeof(String), "[skAdmins] %s te explodiu.", skNome(playerid));
	SendClientMessage(strval(params), COR_ERRO, String);
	SendClientMessage(playerid, -1, "[skAdmins] Jogador(a) explodido(a).");
	return 1;
}

CMD:trazer(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	if(!strlen(params) || !IsNum(params)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /Trazer [ID]");
	if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
	GetPlayerPos(playerid, X, Y, Z);
	SetPlayerPos(strval(params), X, Y, Z+1);
	new String[50];
	format(String, sizeof(String), "[skAdmins] {1E90FF}%s{A9A9A9} te trouxe.", skNome(playerid));
	SendClientMessage(strval(params), COR_AZUL, String);
	SendClientMessage(playerid, COR_AZUL, "[skAdmins] Jogador(a) trazido(a).");
	return 1;
}

CMD:setarpontos(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	new ID, Pontos;
	if(sscanf(params, "id", ID, Pontos)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /SetarPontos [ID] [Pontos]");
 	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
 	SetPlayerScore(ID, Pontos);
	new skFile[50];
	format(skFile, sizeof(skFile), skSaves, skNome(ID));
 	DOF2_SetInt(skFile, "Pontos", Pontos);
 	new String[50];
 	format(String, sizeof(String), "[skAdmins] Você setou %d pontos para %s.", Pontos, skNome(ID));
 	SendClientMessage(playerid, COR_AZUL, String);
	format(String, sizeof(String), "[skAdmins] %s te setou %d de pontos.", skNome(playerid), Pontos);
	SendClientMessage(ID, COR_AZUL, String);
	return 1;
}

CMD:darpontos(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	new ID, Pontos;
	if(sscanf(params, "id", ID, Pontos)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /DarPontos [ID] [Pontos]");
 	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Não há nenhum(a) jogador(a) com esse ID!");
 	SetPlayerScore(ID, GetPlayerScore(ID)+Pontos);
 	new skFile[50];
	format(skFile, sizeof(skFile), skSaves, skNome(ID));
 	DOF2_SetInt(skFile, "Pontos", GetPlayerScore(ID)+Pontos);
 	new String[50];
 	format(String, sizeof(String), "[skAdmins] Você deu %d pontos para %s.", Pontos, skNome(ID));
 	SendClientMessage(playerid, COR_AZUL, String);
	format(String, sizeof(String), "[skAdmins] %s te deu %d de pontos.", skNome(playerid), Pontos);
	SendClientMessage(ID, COR_AZUL, String);
	return 1;
}

CMD:dartpontos(playerid, params[])
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	if(!strlen(params) || !IsNum(params)) return SendClientMessage(playerid, COR_AZUL, "[skAdmins] /dartpontos [Pontos]");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
	        SetPlayerScore(i, GetPlayerScore(i)+strval(params));
		 	new skFile[50];
			format(skFile, sizeof(skFile), skSaves, skNome(i));
		 	DOF2_SetInt(skFile, "Pontos", GetPlayerScore(i)+strval(params));
		}
	}
 	new String[80];
	format(String, sizeof(String), "[skAdmins] %s setou %d de score pra todos.", skNome(playerid), strval(params));
	SendClientMessageToAll(COR_AZUL, String);
	return 1;
}

CMD:tdesarmar(playerid)
{
    if(skAdmin[playerid] < 1 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "[ERRO] Você não tem permissão!");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
	        ResetPlayerWeapons(i);
		}
	}
 	new String[80];
	format(String, sizeof(String), "[skAdmins] %s desarmou todos os jogadores.", skNome(playerid));
	SendClientMessageToAll(COR_AZUL, String);
	return 1;
}

CMD:admins(playerid)
{
	new StringAdm[2000], StringAdm2[2000];
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(skAdmin[i] > 0)
			{
				format(StringAdm, sizeof(StringAdm), "{1E90FF}•{FF1E1E}• {FFFFFF}%s - {1E90FF}%d\n\n", skNome(i), skAdmin[i]);
				strcat(StringAdm2, StringAdm);
				ShowPlayerDialog(playerid, skAdmins, DIALOG_STYLE_MSGBOX, "[skAdmins] Staff Online", StringAdm2, "Fechar", "");
			}else{
				ShowPlayerDialog(playerid, skAdmins, DIALOG_STYLE_MSGBOX, "[skAdmins] Staff Online", "Nenhum membro da staff está conectado no momento!", "Fechar", "");
			}
		}
	}
	return 1;
}

CMD:acmds(playerid)
{
	if(skAdmin[playerid] > 0)
 	{
	    new cmdString[500], admString[500];
    	format(admString, sizeof(admString), "{1E90FF}Comandos para administradores nível 1:{FFFFFF}");
	    strcat(cmdString, admString);
	    format(admString, sizeof(admString), "\n/Kick, /Ban, /Ir, /Trazer, /Avisar, /Espiar, /An, /Explodir, /Tapa, /tDesarmar");
	    strcat(cmdString, admString);
	    format(admString, sizeof(admString), "\n/Desarmar, /DarPontos, /DarTPontos, /SetarPontos");
	    strcat(cmdString, admString);
	    if(skAdmin[playerid] > 1)
    	{
  			format(admString, sizeof(admString), "\n\n{1E90FF}Comandos para administradores nível 2:{FFFFFF}");
	    	strcat(cmdString, admString);
  			format(admString, sizeof(admString), "\n/DarAdmin, /FakeCMD, /FakeChat, /FakeBan, /FakeKick");
	    	strcat(cmdString, admString);
		}
	    ShowPlayerDialog(playerid, skAMenu, DIALOG_STYLE_MSGBOX, "[skAdmins] Comandos administrativos", cmdString, "Fechar", "");
	}
	return 1;
}

stock skNome(playerid)
{
	new sknome[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sknome, MAX_PLAYER_NAME);
	return sknome;
}

stock IsNum(const string[])
{
	new length=strlen(string);
	if(length==0) return false;
	for(new i = 0; i < length; i++)
	{
		if((string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+') || (string[i]=='-' && i!=0) || (string[i]=='+' && i!=0)) return false;
	}
	if(length==1 && (string[0]=='-' || string[0]=='+')) return false;
	return true;
}

forward KickP(playerid);
public KickP(playerid)
{
	Kick(playerid);
	return 1;
}

forward BanP(playerid);
public BanP(playerid)
{
	Ban(playerid);
	return 1;
}
