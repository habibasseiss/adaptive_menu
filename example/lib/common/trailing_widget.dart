import 'package:flutter/cupertino.dart';
import 'package:native_menu/adaptive_menu.dart';

class TrailingWidget extends StatefulWidget {
  const TrailingWidget({this.type, super.key});

  final AdaptiveMenuType? type;

  @override
  State<TrailingWidget> createState() => _TrailingWidgetState();
}

class _TrailingWidgetState extends State<TrailingWidget> {
  bool _viewAsIcons = true;
  bool _sortAscending = true;
  String? _sortItem = 'Name';

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenu(
      type: widget.type,
      size: const Size(56, 40),
      items: [
        AdaptiveMenuAction(
          title: 'Select',
          icon: CupertinoIcons.check_mark_circled,
          onPressed: () {
            debugPrint('Select was tapped!');
          },
        ),
        AdaptiveMenuAction(
          title: 'New Folder',
          icon: CupertinoIcons.folder_badge_plus,
          onPressed: () {
            debugPrint('New Folder was tapped!');
          },
        ),
        AdaptiveMenuAction(
          title: 'Scan Documents',
          icon: CupertinoIcons.doc_text_viewfinder,
          onPressed: () {
            debugPrint('Scan Documents was tapped!');
          },
        ),
        AdaptiveMenuGroup.inline(
          actions: [
            AdaptiveMenuAction(
              title: 'Icons',
              icon: CupertinoIcons.rectangle_grid_2x2,
              checked: _viewAsIcons,
              onPressed: () {
                setState(() {
                  _viewAsIcons = true;
                });
                debugPrint('Icons was tapped!');
              },
            ),
            AdaptiveMenuAction(
              title: 'List',
              icon: CupertinoIcons.list_bullet,
              checked: !_viewAsIcons,
              onPressed: () {
                setState(() {
                  _viewAsIcons = false;
                });
                debugPrint('List was tapped!');
              },
            ),
          ],
        ),
        AdaptiveMenuGroup.inline(
          actions: [
            AdaptiveMenuAction(
              title: 'Name',
              icon: _sortItem == 'Name'
                  ? (_sortAscending
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down)
                  : null,
              onPressed: () {
                setState(() {
                  if (_sortItem == 'Name') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortItem = 'Name';
                    _sortAscending = true;
                  }
                });
                debugPrint('Name was tapped!');
              },
            ),
            AdaptiveMenuAction(
              title: 'Type',
              icon: _sortItem == 'Type'
                  ? (_sortAscending
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down)
                  : null,
              onPressed: () {
                setState(() {
                  if (_sortItem == 'Type') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortItem = 'Type';
                    _sortAscending = true;
                  }
                });
                debugPrint('Type was tapped!');
              },
            ),
          ],
        ),
        AdaptiveMenuAction(
          title: 'View Options',
          description: 'Extra options for this item',
          onPressed: () {
            debugPrint('View Options was tapped!');
          },
        ),
        AdaptiveMenuGroup.inline(
          actions: [
            AdaptiveMenuAction.destructive(
              title: 'Delete',
              icon: CupertinoIcons.trash,
              onPressed: () {
                debugPrint('Delete was tapped!');
              },
            ),
          ],
        ),
      ],
      child: Icon(CupertinoIcons.ellipsis_circle, size: 26),
    );
  }
}
