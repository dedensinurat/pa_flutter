  import 'package:flutter/material.dart';
  import '../models/jadwal_model.dart';
  import '../services/jadwal_service.dart';
  import '../pages/jadwal_detail_page.dart';

  class JadwalListWidget extends StatefulWidget {
    final int maxItems;
    final bool showTitle;
    final VoidCallback? onViewAllPressed;
    
    const JadwalListWidget({
      Key? key,
      this.maxItems = 3,
      this.showTitle = true,
      this.onViewAllPressed,
    }) : super(key: key);

    @override
    State<JadwalListWidget> createState() => _JadwalListWidgetState();
  }

  class _JadwalListWidgetState extends State<JadwalListWidget> {
    late Future<List<Jadwal>> _futureJadwal;
    bool _isLoading = false;

    @override
    void initState() {
      super.initState();
      _futureJadwal = _fetchJadwal();
    }

    Future<List<Jadwal>> _fetchJadwal() async {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final jadwals = await JadwalService.getJadwal();
        setState(() {
          _isLoading = false;
        });
        return jadwals;
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        throw e;
      }
    }

    Future<void> _refreshData() async {
      setState(() {
        _futureJadwal = _fetchJadwal();
      });
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Text(
                    'Jadwal Seminar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onViewAllPressed != null)
                    TextButton(
                      onPressed: widget.onViewAllPressed,
                      child: const Text('Lihat Semua'),
                    ),
                ],
              ),
            ),
          
          FutureBuilder<List<Jadwal>>(
            future: _futureJadwal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Belum ada jadwal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Limit the number of items to display
              final jadwals = snapshot.data!;
              final displayedJadwals = jadwals.length > widget.maxItems 
                  ? jadwals.sublist(0, widget.maxItems) 
                  : jadwals;
              
              return Column(
                children: [
                  ...displayedJadwals.map((jadwal) => _buildJadwalItem(context, jadwal)),
                  if (jadwals.length > widget.maxItems && widget.onViewAllPressed != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: widget.onViewAllPressed,
                        child: Text('Lihat ${jadwals.length - widget.maxItems} lainnya'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      );
    }

    Widget _buildJadwalItem(BuildContext context, Jadwal jadwal) {
      final isUpcoming = jadwal.isUpcoming();
      final statusColor = jadwal.getStatusColor();
      
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JadwalDetailPage(jadwalId: jadwal.id),
              ),
            ).then((_) => _refreshData());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isUpcoming ? Icons.event_available : Icons.event_busy,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.kelompokNama ?? 'Kelompok ${jadwal.kelompokId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${jadwal.getFormattedDate()} ${jadwal.getFormattedTime()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jadwal.ruangan,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jadwal.getStatusText(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
