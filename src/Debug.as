// c 2024-01-30
// m 2024-01-30

void RenderDebug() {
    if (!S_Debug)
        return;

    UI::Begin(title + " Debug", S_Debug, UI::WindowFlags::None);
        UI::Text("click any value to copy it to your clipboard");

        if (UI::BeginTable("##table-debug", 19, UI::TableFlags::Resizable | UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("authorId");
            UI::TableSetupColumn("authorTime");
            UI::TableSetupColumn("bronzeTime");
            UI::TableSetupColumn("downloadUrl");
            UI::TableSetupColumn("favorite");
            UI::TableSetupColumn("goldTime");
            UI::TableSetupColumn("id");
            UI::TableSetupColumn("laps");
            UI::TableSetupColumn("nameClean");
            UI::TableSetupColumn("nameColored");
            UI::TableSetupColumn("nameQuoted");
            UI::TableSetupColumn("nameRaw");
            UI::TableSetupColumn("number");
            UI::TableSetupColumn("silverTime");
            UI::TableSetupColumn("submitterId");
            UI::TableSetupColumn("thumbnailUrl");
            UI::TableSetupColumn("uid");
            UI::TableSetupColumn("updateTimestamp");
            UI::TableSetupColumn("uploadTimestamp");
            UI::TableHeadersRow();

            UI::ListClipper clipper(maps.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Map@ map = maps[i];

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    if (UI::Selectable(map.authorId, false))
                        IO::SetClipboard(map.authorId);

                    UI::TableNextColumn();
                    string at = Time::Format(map.authorTime);
                    if (UI::Selectable(at, false))
                        IO::SetClipboard(at);

                    UI::TableNextColumn();
                    string bt = Time::Format(map.bronzeTime);
                    if (UI::Selectable(bt, false))
                        IO::SetClipboard(bt);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.downloadUrl, false))
                        IO::SetClipboard(map.downloadUrl);

                    UI::TableNextColumn();
                    string fav = tostring(map.favorite);
                    if (UI::Selectable(fav, false))
                        IO::SetClipboard(fav);

                    UI::TableNextColumn();
                    string gt = Time::Format(map.goldTime);
                    if (UI::Selectable(gt, false))
                        IO::SetClipboard(gt);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.id, false))
                        IO::SetClipboard(map.id);

                    UI::TableNextColumn();
                    string laps = tostring(map.laps);
                    if (UI::Selectable(laps, false))
                        IO::SetClipboard(laps);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.nameClean, false))
                        IO::SetClipboard(map.nameClean);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.nameColored, false))
                        IO::SetClipboard(map.nameColored);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.nameQuoted, false))
                        IO::SetClipboard(map.nameQuoted);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.nameRaw, false))
                        IO::SetClipboard(map.nameRaw);

                    UI::TableNextColumn();
                    string num = tostring(map.number);
                    if (UI::Selectable(num, false))
                        IO::SetClipboard(num);

                    UI::TableNextColumn();
                    string st = Time::Format(map.silverTime);
                    if (UI::Selectable(st, false))
                        IO::SetClipboard(st);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.submitterId, false))
                        IO::SetClipboard(map.submitterId);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.thumbnailUrl, false))
                        IO::SetClipboard(map.thumbnailUrl);

                    UI::TableNextColumn();
                    if (UI::Selectable(map.uid, false))
                        IO::SetClipboard(map.uid);

                    UI::TableNextColumn();
                    string update = tostring(map.updateTimestamp);
                    if (UI::Selectable(update, false))
                        IO::SetClipboard(update);

                    UI::TableNextColumn();
                    string upload = tostring(map.uploadTimestamp);
                    if (UI::Selectable(upload, false))
                        IO::SetClipboard(upload);
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }
    UI::End();
}