# getcigar-3d-models

## Актуальная модель модульного бокса

**Последняя версия: v10 Light** — из v9 вычтен материал только на внутренних поверхностях свободных боковых сотовых стенок. Геометрия стыков и габариты сохраняются. **Статус: экспериментальная версия, реальный вес в Elegoo Slicer и физическая прочность ещё не подтверждены.**

- [STL v10 Light для печати на торце](stl/box80_v10_light_PRINT_ON_END_150x120x350.stl)
- [Исходник OpenSCAD v10 Light](src/box80_v10/box80_v10_light.scad)
- [Изменения, совместимость и проверки v10](docs/box80_v10_light_README.md)

**Предыдущие версии не перезаписаны:**

- [v9 Light STL](stl/box80_v9_light_PRINT_ON_END_150x120x350.stl), [документация v9](docs/box80_v9_light_README.md)
- [v8 STL](stl/box80_v8_honeycomb_sidewalls_PRINT_ON_END_150x120x350.stl), [документация v8](src/box80_v8/README.md)

**Правило версий:** каждая новая модель `v9`, `v10` и т. д. получает собственные файлы с номером версии в имени; архивные STL никогда не перезаписываются. README обновляется с явным указанием актуальной версии.

## Актуальная корзина для модульного бокса

**Basket v6 LONG** — отдельная удлинённая корзина **140×376×98 мм**, основана на последней стандартной v5. Сетка удлинена вставкой 26 мм без растягивания существующих сот, на фасаде справа от этикетки углублённая буква **L** (Long). Сборка и проверка CAD прошли, физическая печать пока не испытана.

- [STL Basket v6 LONG, 376 мм](stl/L_gridfinity_30mm_center_rib/basket_140x376_v6_LONG_L.stl)
- [Скрипт сборки Basket LONG](src/basket_v6_long/build_basket_v6_long.py)
- [Описание и проверки Basket LONG](docs/basket_v6_LONG_README.md)

**Стандартная корзина осталась v5, глубина 350 мм, высота 98 мм:**

- [STL корзины v5](stl/L_gridfinity_30mm_center_rib/basket_140x350_v5_height98.stl)
- [Скрипт v5](src/basket_v5/build_basket_v5_height98.py)
- [Описание v5](docs/basket_v5_height98_README.md)
- [v4, высота 100 мм (архив)](stl/L_gridfinity_30mm_center_rib/basket_140x350_v4_curved_rim.stl)
- [v3 (архив)](stl/L_gridfinity_30mm_center_rib/basket_140x350_v3_finger_scoop.stl)
- [v2 (архив)](stl/L_gridfinity_30mm_center_rib/basket_140x350_v2_reinforced_label_75x40.stl)

## Сначала прочитать

**[DRAWER_REQUIREMENTS.md](DRAWER_REQUIREMENTS.md)** — единое техническое задание на ящики, направляющие и крепления. Перед любыми изменениями моделей OpenSCAD/STL сначала читать этот файл. Изменения требований и результаты физической печати вносятся туда же.

## История прототипов

- `src/`, `stl/` — исходные модели OpenSCAD и экспортированные STL.
- `docs/` — инструкции к отдельным экспериментальным версиям.

Предыдущие сборки v1.0 и v1.1 экспериментальные, не рассчитаны на эксплуатацию с нагрузкой. Новый прототип должен учитывать замечания в `DRAWER_REQUIREMENTS.md`.
