import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:baby/home/color.dart';

class BabyLibraryPage extends StatefulWidget {
  const BabyLibraryPage({Key? key}) : super(key: key);

  @override
  _BabyLibraryPageState createState() => _BabyLibraryPageState();
}

class _BabyLibraryPageState extends State<BabyLibraryPage> {
  final List<LibraryItem> _libraryItems = [];
  List<LibraryItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadLibraryItems();
  }

  Future<void> _loadLibraryItems() async {
    setState(() => _isLoading = true);

    try {
      _libraryItems.addAll(_generateLibraryItems());
      _applyFilters();
    } catch (e) {
      print('Error fetching library items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<LibraryItem> _generateLibraryItems() {
    return [
      // Category 1
      LibraryItem(
          title:
              'The Effect of Kangaroo Care on Behavioral Responses to Pain of an Intramuscular Injection in Neonates',
          date: DateTime.now().subtract(Duration(days: 1)),
          category: 'Category 1',
          pdfPath: 'articles/article (1).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Effect of breast-feeding on pain relief during infant immunization injections',
          date: DateTime.now().subtract(Duration(days: 2)),
          category: 'Category 1',
          pdfPath: 'articles/article (2).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Breastfeeding for Procedural Pain in Infants Beyond the Neonatal Period',
          date: DateTime.now().subtract(Duration(days: 3)),
          category: 'Category 1',
          pdfPath: 'articles/article (3).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Effects of Breastfeeding on Pain Relief in Full-term Newborns',
          date: DateTime.now().subtract(Duration(days: 4)),
          category: 'Category 1',
          pdfPath: 'articles/article (4).pdf',
          isAsset: true),
      LibraryItem(
          title: 'Breastfeeding is an essential complement to vaccination',
          date: DateTime.now().subtract(Duration(days: 5)),
          category: 'Category 1',
          pdfPath: 'articles/article (5).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'The use of breast-feeding for pain relief during neonatal immunization injections',
          date: DateTime.now().subtract(Duration(days: 7)),
          category: 'Category 1',
          pdfPath: 'articles/article (7).pdf',
          isAsset: true),
      LibraryItem(
          title: 'Beta Endorphin Concentrations in Human Milk',
          date: DateTime.now().subtract(Duration(days: 8)),
          category: 'Category 1',
          pdfPath: 'articles/article (8).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Reducing pain during vaccine injections: clinical practice guideline',
          date: DateTime.now().subtract(Duration(days: 11)),
          category: 'Category 1',
          pdfPath: 'articles/article (11).pdf',
          isAsset: true),
      LibraryItem(
          title: 'NURSING & HEALTHCARE',
          date: DateTime.now().subtract(Duration(days: 12)),
          category: 'Category 1',
          pdfPath: 'articles/article (12).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Breast Feeding as Analgesia in Neonates: A Randomized Controlled Trial',
          date: DateTime.now().subtract(Duration(days: 13)),
          category: 'Category 1',
          pdfPath: 'articles/article (13).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Effect of Breast-Feeding and Maternal Holding in Relieving Painful Responses in Full-Term Neonates',
          date: DateTime.now().subtract(Duration(days: 14)),
          category: 'Category 1',
          pdfPath: 'articles/article (14).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'ANALGESIC EFFECT OF DIRECT BREASTFEEDING DURING BCG VACCINATION IN HEALTHY NEONATES',
          date: DateTime.now().subtract(Duration(days: 15)),
          category: 'Category 1',
          pdfPath: 'articles/article (15).pdf',
          isAsset: true),
      LibraryItem(
          title: 'Pourquoi l'
              'effet antalgique de l'
              'allaitement maternel est-il si peu utilisé par les soignants lors des soins chez les bébés ?',
          date: DateTime.now().subtract(Duration(days: 16)),
          category: 'Category 1',
          pdfPath: 'articles/article (16).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Breastfeeding for procedural pain in infants beyond the neonatal period (Protocol)',
          date: DateTime.now().subtract(Duration(days: 17)),
          category: 'Category 1',
          pdfPath: 'articles/article (17).pdf',
          isAsset: true),

      // Category 2
      LibraryItem(
          title: 'Children'
              's Memory for Pain: Overview and Implications for Practice',
          date: DateTime.now().subtract(Duration(days: 6)),
          category: 'Category 2',
          pdfPath: 'articles/article (6).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Consequences of Inadequate Analgesia During Painful Procedures in Children',
          date: DateTime.now().subtract(Duration(days: 9)),
          category: 'Category 2',
          pdfPath: 'articles/article (9).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'A quasiexperimental study to assess the perception of pain in infants aftor intramuscular vaccination',
          date: DateTime.now().subtract(Duration(days: 34)),
          category: 'Category 2',
          pdfPath: 'articles/article (34).pdf',
          isAsset: true),

      // Category 3
      LibraryItem(
          title: 'Prevention and Management of Pain in the Neonate: An Update',
          date: DateTime.now().subtract(Duration(days: 10)),
          category: 'Category 3',
          pdfPath: 'articles/article (10).pdf',
          isAsset: true),
      LibraryItem(
          title: 'Interventions to Reduce Pain during Vaccination in Infancy',
          date: DateTime.now().subtract(Duration(days: 18)),
          category: 'Category 3',
          pdfPath: 'articles/article (18).pdf',
          isAsset: true),
      LibraryItem(
          title:
              'Strategies for the Prevention and Management of Neonatal and Infant Pain',
          date: DateTime.now().subtract(Duration(days: 20)),
          category: 'Category 3',
          pdfPath: 'articles/article (20).pdf',
          isAsset: true),
    ];
  }

  void _applyFilters() {
    _filterLibraryItems(_searchController.text);
    _sortLibraryItems();
  }

  void _filterLibraryItems(String query) {
    final queryLower = query.toLowerCase();
    setState(() {
      _filteredItems = _libraryItems.where((item) {
        final matchesQuery = item.title.toLowerCase().contains(queryLower);
        final matchesCategory =
            _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _sortLibraryItems() {
    setState(() {
      _filteredItems.sort((a, b) =>
          _isAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use AppColors for background
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(), // Call method for sliver app bar
          SliverToBoxAdapter(child: _buildSearchBar()), // Search bar widget
          SliverToBoxAdapter(child: _buildCategoryFilter()), // Category filter
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            sliver: _buildLibraryContent(), // Library content grid
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_filteredItems.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child:
              Text('No items found', style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return LibraryItemWidget(
            item: _filteredItems[index],
            onTap: _showPreview,
            onShare: _shareItem,
          );
        },
        childCount: _filteredItems.length,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Medical Library',
          style: TextStyle(color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 90, 21, 210),
                Color.fromARGB(255, 64, 13, 153)
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_hospital, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Pediatric Resources',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search medical resources',
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
        ),
        onChanged: _filterLibraryItems,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Category 1',
      'Category 2',
      'Category 3',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                selectedColor: Colors.blue[100],
                onSelected: (isSelected) {
                  setState(() {
                    _selectedCategory = isSelected ? category : 'All';
                    _filterLibraryItems(_searchController.text);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPreview(LibraryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewPage(item: item),
      ),
    );
  }

  void _shareItem(LibraryItem item) async {
    try {
      if (item.isAsset) {
        final ByteData bytes = await rootBundle.load(item.pdfPath);
        final Uint8List list = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${path.basename(item.pdfPath)}');
        await tempFile.writeAsBytes(list);
        await Share.shareFiles([tempFile.path], text: item.title);
      } else {
        await Share.shareFiles([item.pdfPath], text: item.title);
      }
    } catch (e) {
      print('Error sharing item: $e');
    }
  }
}

class LibraryItem {
  final String title;
  final DateTime date;
  final String category;
  final String pdfPath;
  final bool isAsset;

  const LibraryItem({
    required this.title,
    required this.date,
    required this.category,
    required this.pdfPath,
    required this.isAsset,
  });
}

class LibraryItemWidget extends StatelessWidget {
  final LibraryItem item;
  final Function(LibraryItem) onTap;
  final Function(LibraryItem) onShare;

  const LibraryItemWidget({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(item),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: SvgPicture.asset(
                  'image/svg/pdf.svg', // Replace with your SVG asset path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(item.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.purple),
                    onPressed: () => onShare(item),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFPreviewPage extends StatelessWidget {
  final LibraryItem item;

  const PDFPreviewPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: FutureBuilder<String>(
        future: _loadPdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading PDF'));
          } else if (snapshot.hasData) {
            return PDFView(filePath: snapshot.data!);
          } else {
            return const Center(child: Text('No PDF data available'));
          }
        },
      ),
    );
  }

  Future<String> _loadPdf() async {
    if (item.isAsset) {
      final ByteData bytes = await rootBundle.load(item.pdfPath);
      final Uint8List list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${path.basename(item.pdfPath)}');
      await file.writeAsBytes(list);
      return file.path;
    } else {
      return item.pdfPath;
    }
  }
}
