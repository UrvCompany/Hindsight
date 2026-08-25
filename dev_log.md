# Dev Log


### 26.08.2026

## Визуальное выделение текущего режима

Добавлено автоматическое выделение активного режима Exploration / Thinking / Notes через outline текста. При загрузке ModeSwitch определяется текущее состояние из SceneStateGlobal.current_state, после чего соответствующий Label получает обводку. Это позволяет сохранять визуальное выделение текущего режима после перехода между сценами без дополнительных узлов.

**Файлы:** mode_switch.gd

**Сущности:** update_mode_outline(), font_outline_color, outline_size, SceneStateGlobal.current_state

## Переход по лестнице вверх

Добавлен переход через левую область лестницы в предыдущую/общую сцену. При наведении на область отображается визуальное выделение лестницы и устанавливается курсор со стрелкой вверх. При нажатии происходит переход в указанную через Inspector сцену. Курсор принудительно сбрасывается перед сменой сцены, чтобы кастомная текстура не оставалась после уничтожения текущей сцены.

**Файлы:** castle_interior_left.gd, соответствующая сцена интерьера замка

**Сущности:** Area2D, Stairs_outline, general_scene_path, cursor_texture, Input.set_custom_mouse_cursor(), interact()

-------------------------------------------------------------------------------
### 23.08.2026

## Механика заполнения пропусков в тексте

Реализована система интерактивных пропусков в RichTextLabel. Каждый пропуск размечается через [u][url=slot_N]...[/url][/u], где slot_N идентифицирует конкретную позицию. Игрок может перетаскивать слова из WordsBar непосредственно на пропуски.

**Файлы:** Basic_plane.gd, Basic_plane_rich_text.gd

**Сущности:** BasicPlane, Basic_plane_rich_text, Basic_plane_chapter_1, slot_N, setup_text(), slot_words

## Drag & Drop в RichTextLabel

Basic_plane_rich_text настроен как Drop Target для строк, получаемых от кнопок WordsBar. Добавлена обработка _can_drop_data() и _drop_data(). При наведении на конкретный [url=slot_N] определяется соответствующий слот, после чего перетащенное слово записывается в него.

**Файлы:** Basic_plane_rich_text.gd, words_button.gd

**Сущности:** _get_drag_data(), _can_drop_data(), _drop_data(), meta_hover_started, meta_hover_ended, hovered_slot

## Замена слов в пропусках

Добавлена возможность повторно перетаскивать слова в уже заполненный слот. Новое слово заменяет предыдущее значение, что позволяет игроку исправлять собственный вариант после неудачной проверки.

**Файлы:** Basic_plane_rich_text.gd

**Сущности:** slot_words, update_text()

## Проверка итоговой версии

Добавлена проверка собранной игроком версии после заполнения всех пропусков. До заполнения всех слотов проверка не запускается. После заполнения последнего пропуска все значения slot_words сравниваются с эталонным массивом CORRECT_ANSWERS. Результат определяется как ПРАВИЛЬНО или НЕПРАВИЛЬНО.

**Файлы:** Basic_plane.gd, Basic_plane_rich_text.gd

**Сущности:** CORRECT_ANSWERS, correct_answers, check_answers()

## Реакция на неправильный ответ

Добавлена визуальная реакция на неправильную итоговую комбинацию. При полном заполнении пропусков и ошибочном ответе отображается спрайт LOH. При правильном ответе LOH скрывается.

**Файлы:** Basic_plane.gd, Basic_plane_rich_text.gd, Basic_plan.tscn

**Сущности:** LOH, set_loh(), loh.visible

-------------------------------------------------------------------------------
### 23.08.2026**

**## Механика заполнения пропусков в тексте**

Начата реализация механики, при которой игрок перетаскивает собранные в WordsBar слова непосредственно в пропуски текста. Пропуски размечаются в `RichTextLabel` через `[u][url=slot_N]...[/url][/u]`, где `slot_N` идентифицирует конкретную позицию. Правильные ответы хранятся отдельно от текста и используются только при последующей проверке итоговой версии игрока.

****Файлы:**** `Basic_plane.gd`, `Basic_plane_rich_text.gd`

****Сущности:**** `BasicPlane`, `Basic_plane_rich_text`, `Basic_plane_chapter_1`, `CORRECT_ANSWERS`, `slot_N`, `slot_words`, `setup_text()`, `update_text()`

**## Drag & Drop слов из WordsBar**

Добавлен приём слов из WordsBar через Drag & Drop непосредственно в `RichTextLabel`. `Basic_plane_rich_text` теперь выступает в качестве Drop Target и принимает строки, перетаскиваемые кнопками WordsBar. Реализованы `_can_drop_data()` и `_drop_data()`.

****Файлы:**** `Basic_plane_rich_text.gd`, `words_button.gd`

****Сущности:**** `_get_drag_data()`, `_can_drop_data()`, `_drop_data()`, `set_drag_preview()`

**## Привязка слова к конкретному пропуску**

Добавлено определение активного `slot_N` через meta-события `RichTextLabel`. При наведении курсора на размеченный `[url=slot_N]` запоминается соответствующий слот, после чего при Drop слово записывается именно в него. Повторный Drop в тот же слот заменяет ранее установленное слово.

****Файлы:**** `Basic_plane_rich_text.gd`

****Сущности:**** `meta_hover_started`, `meta_hover_ended`, `hovered_slot`, `slot_words`

**## Динамическая замена пропусков**

После установки слова содержимое соответствующего `[url=slot_N]` заменяется на выбранное игроком слово без изменения остального текста. Количество пропусков и их расположение задаются непосредственно разметкой текста, поэтому механика не привязана к конкретному уровню или фиксированному количеству слотов.

****Файлы:**** `Basic_plane_rich_text.gd`, `Basic_plane.gd`

****Сущности:**** `update_text()`, `original_text`, `slot_words`, `url=slot_N`

**## Разделение пользовательского решения и правильных ответов**

Правильные ответы отделены от текста и от текущих значений слотов игрока. `CORRECT_ANSWERS` содержит эталонную последовательность ответов, а `slot_words` — фактически собранную игроком версию. Проверка будет выполняться после заполнения всей конструкции, а не при каждом отдельном Drop.

****Файлы:**** `Basic_plane.gd`, `Basic_plane_rich_text.gd`

****Сущности:**** `CORRECT_ANSWERS`, `slot_words`


-------------------------------------------------------------------------------
### 22.08.2026


## Переход Castle_interior ↔ Castle_interior_second

Кликабельная область на двери, при наведении курсор меняется на стрелку (вправо/влево), по клику переключает сцену. Курсор явно сбрасывается перед сменой сцены — иначе кастомная текстура зависала навсегда (mouse_exited не успевает сработать при мгновенном уничтожении узла).

**Файлы:** `castle_interior_second_entrance.gd`, `Castle_interior.tscn`, `Castle_interior_second.tscn`
**Сущности:** `CastleInteriorSecondScene`, `BackToCastleInterior`, `target_scene_path`, `cursor_texture`, `Input.set_custom_mouse_cursor()`



## Королевский указ (DecreeBoard)

Кликабельная табличка на стене открывает изображение указа с текстом; два слова ("3 м", "всех") собираются в WordsBar по клику.

**Файлы:** `Decree_board.tscn` (тип корня Node2D → Area2D, иначе клики не ловились), `decree_board.gd`, `Castle_interior_second.gd`, `Castle_interior_second.tscn`
**Сущности:** `DecreeBoard`, `board_clicked`, `royal_decree.jpeg`

## Затемнение интерфейса при чтении

При открытии книги/указа кнопки режимов (Exploration/Thinking/Notes) должны были скрываться — потребовалось отдельно прятать CanvasLayer с текстом, т.к. он всегда рисуется поверх независимо от порядка узлов. Заодно поправлена вложенность WordsBar (была случайно внутри ModeSwitch в одной из сцен — пряталась бы вместе с кнопками).

**Файлы:** `mode_switch.gd`, `Notes_scene.gd`, `Castle_interior_second.gd`, `Castle_interior_second.tscn`
**Сущности:** `set_ui_visible()`



## Концепция "вспомогательные сцены"

Book_spread и decree_reader объединены в общий переиспользуемый механизм: открываются на части экрана (размер задаёт сама вспомогательная сцена), фон затемняется на 50%, закрытие по Esc или клику вне вспомогательной сцены. WordsBar теперь отдельный CanvasLayer поверх всего, включая вспомогательные сцены. Обе читалки переведены с Area2D на Control — клики за пределами блока естественно проваливаются на затемнение без ручной обработки input_event.

**Файлы:** `supporting_scene_manager.gd`, `supporting_scene_manager.tscn`, `project.godot` (автозагрузка), `Words_bar.tscn`, `words_bar.gd`, `book_spread.tscn`, `book_spread.gd`, `decree_reader.tscn`, `decree_reader.gd`, `Notes_scene.gd`, `Notes_scene.tscn`, `Castle_interior_second.gd`, `Castle_interior_second.tscn`
**Сущности:** `SupportingSceneManager` (autoload), `open()`/`close()`, `opened`/`closed`/`word_collected` сигналы, `BookSpread`, `DecreeReader` (class_name)



## Баг подчёркивания в RichTextLabel

Слово "всех" в указе не подчёркивалось, хотя тег `[u][url=...]` был на месте и клик работал. Причина найдена: пустая строка (`\n\n`) внутри текста одного `RichTextLabel` ломает отрисовку `[u]` для форматирования сразу после разрыва абзаца — сам тег парсится и кликается корректно, просто визуально не рисуется. В книге эта проблема не проявлялась, т.к. абзацы там были на двух разных узлах. Указ переведён на ту же схему — два отдельных `RichTextLabel` вместо одного с `\n\n`.

**Файлы:** `decree_reader.tscn`, `decree_reader.gd`
**Сущности:** `Paragraph1`, `Paragraph2`



## Починка `@export_multiline` на массиве

`@export_multiline` был по ошибке применён к `Array[String]` (`book_texts` в `Notes_scene.gd`) — эта аннотация предназначена только для `String`. Из-за этого скрипт не проходил валидацию, и **все** экспортируемые переменные `NotesScene` пропадали из инспектора, не только `book_texts`.

**Файлы:** `Notes_scene.gd`
**Сущности:** `book_texts` → `@export` вместо `@export_multiline`



## Текст книги и указа перенесён в код

По аналогии с `decree_reader.gd` текст книги теперь хранится как `const` прямо в скрипте, а не в экспортируемом поле/`.tscn`. Заодно везде убрана склейка абзацев через `\n\n` + `split()` — раньше это скрытое допущение (разделитель никогда не долетает до `RichTextLabel` как единая строка) держалось только на аккуратности, теперь оба абзаца — независимые строки/поля без разбора на рантайме.

**Файлы:** `Notes_scene.gd`, `Notes_scene.tscn`, `book.gd`, `book_spread.gd`
**Сущности:** `BOOK_TEXTS_1`/`BOOK_TEXTS_2`, `Book.page_text_1`/`page_text_2`, `BookSpread.set_text(text_1, text_2)`


-------------------------------------------------------------------------------

### 20.08.2026


## Раздел Notes

Полка с процедурно генерируемым на уровень числом книг, открытие/закрытие книги в общий разворот.

**Файлы:** `Notes_scene.tscn`, `Notes_scene.gd`, `book.gd`, `Book.tscn`, `Scene_state.gd`
**Сущности:** `Book` (class_name), `BooksContainer`, `Reader`, `generate_books()`, `_open_reader()`, `_close_reader()`, `books_per_level`



## Починка переключения режимов

Сломанный переход в Thinking (устаревший путь к текстуре после переноса картинок), не подключённый переход в Notes, книги перекрывали табличку режимов, надпись Notes была серой из-за фона кнопки.

**Файлы:** `mode_switch.gd`, `Mode_switch.tscn`, `Thinking_scene.tscn`, `Notes_scene.tscn`
**Сущности:** `notes_scene_path`, `current_scene` (запоминание исходной сцены при выходе из Exploration), `Button.flat`, порядок узлов в дереве сцены



## Механика сбора слов

Слоты на WordsBar (маркер + рамка + подпись), раздача слов по слотам.

**Файлы:** `words_bar.gd`, `Words_bar.tscn`, `words.tscn`, `Scene_state.gd`
**Сущности:** группа `Words_slots`, `set_words()`, `add_word()`, `collected_words`



## Читаемый текст в книге

Добавлен текст в книгу (2 записи с кликабельными подчёркнутыми словами: "6 м", "ров", "3 м"), клик по слову сохраняет его в WordsBar.

**Файлы:** `Notes_scene.tscn`, `Notes_scene.gd`, `book.gd`
**Сущности:** `RichTextLabel`, `RichTextLabel2`, `page_text`, `_on_reader_text_meta_clicked()`



## Починка перехода Castle_wall → Castle_interior

Не был заполнен путь к сцене, сигналы Area2D были подключены не к тому узлу.

**Файлы:** `castle_wall.tscn`
**Сущности:** `WallStairs` (`input_event`, `mouse_entered`, `mouse_exited`)
-------------------------------------------------------------------------------


