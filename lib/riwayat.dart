import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'riwayat_service.dart';
import 'riwayat_model.dart';

class RiwayatHistoriScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  const RiwayatHistoriScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<RiwayatHistoriScreen> createState() => _RiwayatHistoriScreenState();
}

class _RiwayatHistoriScreenState extends State<RiwayatHistoriScreen> {
  late TextEditingController _rangeDateController;
  late ScrollController _scrollController;

  List<SensorData> _dataList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 10;

  String? _startDate;
  String? _endDate;
  String? deviceName;

  /// Dummy device name (Anda bisa menggantinya dengan nilai nyata dari API)

  @override
  void initState() {
    super.initState();
    _rangeDateController = TextEditingController();
    _scrollController = ScrollController();
    _fetchData(page: 1);
    _setupScrollListener();
  }

  @override
  void dispose() {
    _rangeDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchData(page: _currentPage + 1);
      }
    });
  }

  Future<void> _fetchData({required int page}) async {
    if (_isLoading || (!_hasMore && page != 1)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RiwayatService.fetchSensorHistory(
        widget.deviceId,
        startDate: _startDate,
        endDate: _endDate,
        limit: _limit,
        page: page,
      );

      if (response.items.isEmpty) {
        if (page == 1) {
          setState(() {
            _dataList.clear();
          });
        }
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          if (page == 1) {
            _dataList = response.items; // Menggunakan response.items
          } else {
            _dataList.addAll(response.items); // Menambahkan item baru
          }
          _currentPage = page;
          _hasMore = response.totalPages > page;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 7)),
        end: DateTime.now(),
      ),
    );

    if (pickedRange != null) {
      if (pickedRange.end.isBefore(pickedRange.start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tanggal akhir tidak boleh sebelum tanggal mulai"),
          ),
        );
        return;
      }

      final start = DateFormat('dd/MM/yyyy').format(pickedRange.start);
      final end = DateFormat('dd/MM/yyyy').format(pickedRange.end);

      _rangeDateController.text = "$start - $end";
      setState(() {
        _startDate = start;
        _endDate = end;
        _currentPage = 1;
        _hasMore = true;
        _dataList.clear();
      });

      _fetchData(page: 1);
    }
  }

  /// Fungsi untuk memberi warna berdasarkan status
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'on':
        return Colors.green;
      case 'off':
        return Colors.red;
      case 'lembab':
        return Colors.green;
      case 'kurang':
        return Colors.red;
      case 'netral':
        return Colors.green;
      case 'basa':
        return Colors.red;
      case 'asam':
        return Colors.red;
      default:
        return Colors.black; // Default color
    }
  }

  Widget buildSensorRow(
    String label,
    String? value, {
    String unit = '',
    TextStyle? style,
  }) {
    return Row(
      children: [
        Text("", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            "${value != null && value.isNotEmpty ? value + unit : '-'}",
            style: style ?? TextStyle(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Data Sensor")),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentPage = 1;
            _hasMore = true;
            _dataList.clear();
          });
          await _fetchData(page: 1);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /// Tampilkan Nama Device dan ID Device
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "${widget.deviceName}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${widget.deviceId}",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),

              SizedBox(height: 16),

              /// Filter Tanggal
              Container(
                height: 42,
                child: TextField(
                  controller: _rangeDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    labelText: "Rentang Tanggal",
                    suffixIcon: Icon(Icons.date_range, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: () => _selectDateRange(context),
                ),
              ),
              SizedBox(height: 16),

              /// Daftar Data Sensor
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _dataList.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _dataList.length) {
                      final item = _dataList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item.timestamp}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Divider(),
                              buildSensorRow("Sensor", item.name),
                              buildSensorRow(
                                "Nilai",
                                "${item.value}",
                                unit: item.unit ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              buildSensorRow(
                                "Status",
                                item.status,
                                style: TextStyle(
                                  color: getStatusColor(item.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child:
                            _isLoading
                                ? CircularProgressIndicator()
                                : Container(),
                      );
                    }
                  },
                ),
              ),
              if (!_hasMore && _dataList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text("Tidak ada data tambahan"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
