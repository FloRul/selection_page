import 'package:flutter/material.dart';
import 'package:selection_page/tile.dart';

class SelectChoicePage<T> extends StatefulWidget {
  const SelectChoicePage({
    required this.choices,
    required this.getDisplayValue,
    required this.onCanceled,
    required this.onChanged,
    super.key,
    this.enableSearch = false,
    this.allowMultiple = false,
    this.initialSelection,
  });
  final List<T> choices;
  final VoidCallback onCanceled;
  final String Function(T) getDisplayValue;
  final bool allowMultiple;
  final void Function(List<T>) onChanged;
  final bool enableSearch;
  final List<T>? initialSelection;

  @override
  State<SelectChoicePage<T>> createState() => _SelectChoicePageState();
}

class _SelectChoicePageState<T> extends State<SelectChoicePage<T>> {
  List<T> _selected = [];
  String _filter = '';
  List<T> _source = [];
  List<T> _filteredSource = [];

  @override
  void initState() {
    super.initState();
    _filter = '';
    _source = widget.choices;
    _filteredSource = _source;
    _selected = widget.initialSelection ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCanceled,
        ),
        bottom: widget.enableSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: theme.colorScheme.outlineVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                    ),
                    onChanged: (value) => setState(() {
                      _filter = value;
                      _filteredSource = _source
                          .where(
                            (element) =>
                                widget.getDisplayValue(element).toLowerCase().startsWith(_filter.toLowerCase()) ||
                                _selected.contains(element),
                          )
                          .toList();
                    }),
                  ),
                ),
              )
            : null,
      ),
      body: HubListView(
        shrinkWrap: _filteredSource.length > 20,
        itemCount: _filteredSource.length,
        tileBuilder: (index) {
          final item = _filteredSource[index];
          return HubListTile(
            title: widget.getDisplayValue(_filteredSource[index]),
            selected: _selected.contains(_filteredSource[index]),
            onTap: () {
              setState(() {
                if (widget.allowMultiple) {
                  if (_selected.contains(item)) {
                    _selected.remove(item);
                  } else {
                    _selected.add(item);
                  }
                } else {
                  _selected
                    ..clear()
                    ..add(item);
                }
                widget.onChanged(_selected);
              });
            },
          );
        },
      ),
    );
  }
}

class SelectGroupedChoicePage<Y, T> extends StatefulWidget {
  const SelectGroupedChoicePage({
    required this.choices,
    required this.getGroupDisplayValue,
    required this.getChoiceDisplayValue,
    required this.onChanged,
    super.key,
    this.allowMultiple = false,
    this.onCanceled,
    this.enableSearch = false,
    this.title,
    this.initialSelection,
  });
  final String? title;
  final Map<Y, List<T>> choices;
  final VoidCallback? onCanceled;
  final String Function(Y) getGroupDisplayValue;
  final String Function(T) getChoiceDisplayValue;
  final bool allowMultiple;
  final void Function(Map<Y, List<T>>) onChanged;
  final bool enableSearch;
  final Map<Y, List<T>>? initialSelection;

  @override
  State<SelectGroupedChoicePage<Y, T>> createState() => _SelectGroupedChoicePageState();
}

class _SelectGroupedChoicePageState<Y, T> extends State<SelectGroupedChoicePage<Y, T>> {
  Map<Y, List<T>> _source = {};
  Map<Y, List<T>> _filteredSource = {};
  Map<Y, List<T>> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection ?? {};
    _source = widget.choices;
    _filteredSource = _source;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: widget.allowMultiple
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () => widget.onChanged(_selected),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Submit'),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        title: widget.title != null ? Text(widget.title!) : null,
        leading: widget.onCanceled != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onCanceled,
              )
            : null,
        bottom: widget.enableSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: theme.colorScheme.outlineVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                    ),
                    onChanged: (value) => setState(() {
                      _filteredSource = Map.fromEntries(
                        _source.entries.map(
                          (entry) => MapEntry(
                            entry.key,
                            entry.value
                                .where(
                                  (element) =>
                                      widget.getChoiceDisplayValue(element).toLowerCase().startsWith(value) ||
                                      (_selected[entry.key]?.contains(element) ?? false),
                                )
                                .toList(),
                          ),
                        ),
                      )..removeWhere(
                          (key, value) => value.isEmpty,
                        );
                    }),
                  ),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: _filteredSource.entries
                .map<Widget>(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.getGroupDisplayValue(entry.key)),
                      Card(
                        elevation: 0,
                        child: HubListView(
                          itemCount: entry.value.length,
                          tileBuilder: (index) {
                            final item = entry.value[index];
                            return HubListTile(
                              title: widget.getChoiceDisplayValue(item),
                              selected: _selected[entry.key]?.contains(item) ?? false,
                              onTap: () {
                                setState(() {
                                  if (widget.allowMultiple) {
                                    if (_selected[entry.key] != null) {
                                      if (_selected[entry.key]!.contains(item)) {
                                        _selected[entry.key]!.remove(item);
                                      } else {
                                        _selected[entry.key]!.add(item);
                                      }
                                    } else {
                                      _selected[entry.key] = [item];
                                    }
                                  } else {
                                    _selected.clear();
                                    _selected[entry.key] = [item];
                                    widget.onChanged(_selected);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
