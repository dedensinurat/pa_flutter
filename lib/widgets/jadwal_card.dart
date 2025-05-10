import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../pages/jadwal_detail_page.dart';

class JadwalCard extends StatelessWidget {
  final Jadwal jadwal;
  final Function? onRefresh;

  const JadwalCard({
    Key? key,
    required this.jadwal,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JadwalDetailPage(jadwalId: jadwal.id),
            ),
          ).then((_) {
            if (onRefresh != null) {
              onRefresh!();
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Seminar ${jadwal.kelompokNama ?? 'Kelompok ${jadwal.kelompokId}'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: jadwal.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jadwal.getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: jadwal.getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date and time
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    jadwal.getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    jadwal.getFormattedTime(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jadwal.ruangan,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Examiners
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Penguji: ${jadwal.penguji1Nama}${jadwal.penguji2Nama != null ? ', ${jadwal.penguji2Nama}' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
