// c 2024-01-29
// m 2024-01-30

dictionary@  accounts     = dictionary();
const string audienceLive = "NadeoLiveServices";
bool         canPlay      = false;
bool         getting      = false;
bool         loadingMap   = false;
Map@[]       maps;
float        scale        = UI::GetScale();
const string title        = "\\$FF0" + Icons::Random + "\\$G Random Favorites";

void Main() {
    NadeoServices::AddAudience(audienceLive);

    if (Permissions::PlayLocalMap())
        canPlay = true;
    else {
        warn("Club access required to play maps");

        if (S_NotifyStarter)
            UI::ShowNotification(title, "Club access is required to play maps, but you can still see the list of your favorites", vec4(1.0f, 0.1f, 0.1f, 0.8f));
    }

    accounts["d2372a08-a8a1-46cb-97fb-23a161d85ad0"] = "Nadeo";

    if (S_Auto)
        startnew(GetFavoriteMaps);
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem(Icons::WindowRestore + " Show window", "", S_Show))
            S_Show = !S_Show;

        if (UI::MenuItem(Icons::Refresh + " Refresh favorites (" + maps.Length + ")", "", false, !getting))
            startnew(GetFavoriteMaps);

        if (UI::MenuItem(Icons::Play + " Play random map", "", false, canPlay && maps.Length > 0 && !loadingMap))
            startnew(PlayRandomMap);

        UI::EndMenu();
    }
}

void Render() {
    if (
        !S_Show ||
        (S_HideWithGame && !UI::IsGameUIVisible()) ||
        (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    UI::SetNextWindowSize(650, 300, UI::Cond::FirstUseEver);

    UI::Begin(title, S_Show, UI::WindowFlags::None);
        UI::BeginDisabled(getting);
        if (UI::Button(Icons::Refresh + " Refresh favorites"))
            startnew(GetFavoriteMaps);
        UI::EndDisabled();

        UI::SameLine();
        UI::BeginDisabled(getting || !canPlay || maps.Length == 0 || loadingMap);
        if (UI::Button(Icons::Play + " Play random map"))
            startnew(PlayRandomMap);
        UI::EndDisabled();

        UI::Text("Click a map name to play it:");

        if (UI::BeginTable("##map-table", 6, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("name");
            UI::TableSetupColumn("author",     UI::TableColumnFlags::WidthFixed, scale * 120);
            UI::TableSetupColumn("authorTime", UI::TableColumnFlags::WidthFixed, scale * 75);
            UI::TableSetupColumn("goldTime",   UI::TableColumnFlags::WidthFixed, scale * 75);
            UI::TableSetupColumn("silverTime", UI::TableColumnFlags::WidthFixed, scale * 75);
            UI::TableSetupColumn("bronzeTime", UI::TableColumnFlags::WidthFixed, scale * 75);
            UI::TableHeadersRow();

            for (uint i = 0; i < maps.Length; i++) {
                Map@ map = maps[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::BeginDisabled(!canPlay || loadingMap);
                if (UI::Selectable(map.nameColored, false))
                    startnew(CoroutineFunc(map.Play));
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::Text(accounts.Exists(map.authorId) ? string(accounts[map.authorId]) : "");

                UI::TableNextColumn();
                UI::Text(Time::Format(map.authorTime));

                UI::TableNextColumn();
                UI::Text(Time::Format(map.goldTime));

                UI::TableNextColumn();
                UI::Text(Time::Format(map.silverTime));

                UI::TableNextColumn();
                UI::Text(Time::Format(map.bronzeTime));
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}