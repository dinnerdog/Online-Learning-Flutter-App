import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:test1/main.dart';

class SearchResult<T> {
  final String title;
  final String subtitle;
  final T data;

  SearchResult(
      {required this.title, required this.subtitle, required this.data});
}

class CustomSearchBar<T> extends StatefulWidget {
  final Future<List<SearchResult<T>>> Function(String) onSearch;
  final void Function(SearchResult<T>) onSelect;
  final String hintText;
  final Widget? body;

  const CustomSearchBar({
    Key? key,
    required this.onSearch,
    required this.onSelect,
    this.hintText = "Search...",
    this.body,
  }) : super(key: key);

  @override
  State<CustomSearchBar<T>> createState() => _CustomSearchBarState<T>();
}

class _CustomSearchBarState<T> extends State<CustomSearchBar<T>> {
  final FloatingSearchBarController _controller = FloatingSearchBarController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      
      
      borderRadius: BorderRadius.circular(20),
      accentColor: AppColors.secondaryColor,
      backgroundColor: AppColors.accentColor,
      iconColor: AppColors.secondaryColor,
      hintStyle: TextStyle(color: AppColors.secondaryColor),
      queryStyle: TextStyle(color: AppColors.secondaryColor),
      automaticallyImplyBackButton: false,
      automaticallyImplyDrawerHamburger: false,
      body: widget.body,
      controller: _controller,
      hint: widget.hintText,
      onQueryChanged: (query) {
        setState(() {});
      },
      builder: (context, _) {
        return FutureBuilder<List<SearchResult<T>>>(
          future: widget.onSearch(_controller.query),
          builder: (context, snapshot) {
            if (_controller.query.isEmpty) {
              return Container();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentColor),
              ));
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            final results = snapshot.data ?? [];

            if (results.isEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: AppColors.accentColor,
                  child: ListTile(
                    title: Text("No activity found",
                        style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                ),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: AppColors.accentColor,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      dense: true,
                      leading:
                          Icon(Icons.event, color: AppColors.secondaryColor),
                      title: Text(result.title,
                          style: TextStyle(color: AppColors.secondaryColor)),
                      subtitle: Text(result.subtitle,
                          style: TextStyle(color: AppColors.secondaryColor)),
                      onTap: () => widget.onSelect(result),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
