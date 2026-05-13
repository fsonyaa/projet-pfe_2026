import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class AdminNlpReportPage extends StatefulWidget {
  @override
  _AdminNlpReportPageState createState() => _AdminNlpReportPageState();
}

class _AdminNlpReportPageState extends State<AdminNlpReportPage> {
  Map<String, dynamic> reportData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_nlp_report'));

      if (response.statusCode == 200) {
        setState(() {
          reportData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur fetch report: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text("Rapport d'Analyse IA NLP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchReport,
          )
        ],
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalBanner(),
                  SizedBox(height: 24),
                  
                  _sectionHeader("Analyse des Sentiments", Icons.analytics_outlined),
                  SizedBox(height: 12),
                  _buildSentimentCard(),
                  
                  SizedBox(height: 24),
                  _sectionHeader("Satisfaction par Parcours", Icons.route_outlined),
                  SizedBox(height: 12),
                  _buildParcoursDashboard(),
                  
                  
                  SizedBox(height: 24),
                  _sectionHeader("Mots-clés IA Détectés", Icons.psychology_outlined),
                  SizedBox(height: 12),
                  _buildKeywordCloud(),
                  
                  SizedBox(height: 24),
                  _sectionHeader("Top Performance Chauffeurs", Icons.star_outline),
                  SizedBox(height: 12),
                  _buildTopDriversList(),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF1A237E), size: 22),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
      ],
    );
  }

  Widget _buildGlobalBanner() {
    double score = (( (reportData['average_sentiment_score'] ?? 0) + 1) * 50);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Text("Satisfaction Globale du Réseau", style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            "${score.toStringAsFixed(1)}%",
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 15,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.comment_outlined, color: Colors.white54, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Basé sur ${reportData['total_avis'] ?? 0} avis analysés",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              if (reportData['safety_alerts_count'] != null && reportData['safety_alerts_count'] > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "${reportData['safety_alerts_count']} alertes sécurité",
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard() {
    Map<String, dynamic> dist = reportData['sentiment_distribution'] ?? {};
    int total = reportData['total_avis'] ?? 1;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(child: _sentimentIndicator("Positifs", dist['Positif'] ?? 0, total, Colors.green)),
          Expanded(child: _sentimentIndicator("Neutres", dist['Neutre'] ?? 0, total, Colors.orange)),
          Expanded(child: _sentimentIndicator("Négatifs", dist['Négatif'] ?? 0, total, Colors.red)),
        ],
      ),
    );
  }

  Widget _sentimentIndicator(String label, int count, int total, Color color) {
    double percent = (count / total) * 100;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: count / total,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 6,
              ),
            ),
            Text("${percent.toStringAsFixed(0)}%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
        Text("$count avis", style: TextStyle(fontSize: 11, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildParcoursDashboard() {
    List stats = reportData['parcours_stats'] ?? [];
    if (stats.isEmpty) return _emptyState("Aucune donnée de parcours");

    return Column(
      children: stats.map<Widget>((p) {
        double score = (((p['avg_sentiment'] ?? 0) + 1) * 50);
        Color statusColor = score >= 70 ? Colors.green : (score >= 40 ? Colors.orange : Colors.red);
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Color(0xFF1A237E).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.directions_bus, color: Color(0xFF1A237E), size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${p['Depart']} ➔ ${p['Arrivee']}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text("${p['nb_avis']} avis clients", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${score.toStringAsFixed(1)}%",
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text("Score IA", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: statusColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showParcoursDetails(p),
                      icon: Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF1A237E)),
                      label: Text("Détails des avis", style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: Color(0xFF1A237E).withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showParcoursDetails(Map<String, dynamic> parcours) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ParcoursAvisSheet(parcours: parcours),
    );
  }


  Widget _buildKeywordCloud() {
    List keywords = reportData['top_keywords'] ?? [];
    if (keywords.isEmpty) return _emptyState("Aucun mot-clé");

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords.map<Widget>((kw) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
            ),
            child: Text(
              "${kw[0]} (${kw[1]})",
              style: TextStyle(fontSize: 12, color: Colors.indigo[800], fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopDriversList() {
    List drivers = reportData['top_drivers'] ?? [];
    if (drivers.isEmpty) return _emptyState("Aucun chauffeur classé");

    return Column(
      children: drivers.map<Widget>((d) {
        double score = (((d['avg_sentiment'] ?? 0) + 1) * 50);
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.withOpacity(0.1),
              child: Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            ),
            title: Text(d['Nom'] ?? "Inconnu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("${d['nb_avis'] ?? 0} avis", style: TextStyle(fontSize: 11)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                "IA: ${score.toStringAsFixed(1)}%",
                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(message, style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ),
    );
  }
}

class _ParcoursAvisSheet extends StatefulWidget {
  final Map<String, dynamic> parcours;
  _ParcoursAvisSheet({required this.parcours});

  @override
  __ParcoursAvisSheetState createState() => __ParcoursAvisSheetState();
}

class __ParcoursAvisSheetState extends State<_ParcoursAvisSheet> {
  List avis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvis();
  }

  Future<void> fetchAvis() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_parcours_reviews/${widget.parcours['ID_parcours']}'));

      if (response.statusCode == 200) {
        setState(() {
          avis = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur fetch avis parcours: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.rate_review_outlined, color: Color(0xFF1A237E)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Avis pour le trajet",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        "${widget.parcours['Depart']} ➔ ${widget.parcours['Arrivee']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                : avis.isEmpty
                    ? Center(child: Text("Aucun avis pour ce trajet", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: avis.length,
                        itemBuilder: (context, index) {
                          final a = avis[index];
                          Color sentimentColor = a['Sentiment_label'] == 'Positif' ? Colors.green : (a['Sentiment_label'] == 'Négatif' ? Colors.red : Colors.orange);
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      a['Nom_Client'] ?? "Anonyme",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                                    ),
                                    Text(
                                      a['Date'].toString().split(' ')[0],
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    ...List.generate(5, (i) => Icon(
                                      Icons.star, 
                                      size: 14, 
                                      color: i < (a['Note'] ?? 0) ? Colors.amber : Colors.grey[300]
                                    )),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sentimentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        a['Sentiment_label'] ?? "Neutre",
                                        style: TextStyle(color: sentimentColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (a['Category'] != null) ...[
                                      SizedBox(width: 8),
                                      Text(
                                        "• ${a['Category']}",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                      ),
                                    ]
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  a['Commentaire'] ?? "Aucun commentaire",
                                  style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
