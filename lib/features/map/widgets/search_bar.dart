import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/gas_station.dart';

class SearchBar extends StatefulWidget {
  final void Function(GasStation) onStationSelected;
  final List<GasStation> stations;

  const SearchBar({
    super.key,
    required this.onStationSelected,
    required this.stations,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<GasStation> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _searchResults = [];
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final query = _controller.text.trim().toLowerCase();
    final results = widget.stations.where((station) {
      return station.name?.toLowerCase().contains(query) ?? false;
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 15,
      right: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Encontrar Posto de Gasolina',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 4.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final station = _searchResults[index];
                    return ListTile(
                      title: Text(station.name ?? 'Posto sem nome'),
                      subtitle: (station.latitude != null && station.longitude != null)
                          ? Text('Lat: ${station.latitude}, Lng: ${station.longitude}')
                          : null,
                      onTap: () {
                        widget.onStationSelected(station);
                        _controller.text = station.name ?? '';
                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
