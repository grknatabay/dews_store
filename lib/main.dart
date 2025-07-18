import 'package:flutter/material.dart';

void main() {
  runApp(const DewsStoreApp());
}

class DewsStoreApp extends StatelessWidget {
  const DewsStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dews Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Yeşil ton
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DewsStoreHomePage(),
    );
  }
}

class DewsStoreHomePage extends StatefulWidget {
  const DewsStoreHomePage({super.key});

  @override
  State<DewsStoreHomePage> createState() => _DewsStoreHomePageState();
}

class _DewsStoreHomePageState extends State<DewsStoreHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  List<Product> _filteredProducts = [];
  List<CartItem> _cartItems = [];
  int _currentBannerIndex = 0;
  late PageController _bannerController;

  final List<Product> _products = [
    Product(
      name: 'Balık Yağı',
      price: '₺89.99',
      image: 'assets/images/balik_yag.webp',
      category: 'Sağlık',
    ),
    Product(
      name: 'Cilt Maskesi',
      price: '₺45.99',
      image: 'assets/images/cilt_maske.jpeg',
      category: 'Cilt Bakımı',
    ),
    Product(
      name: 'D Vitamini',
      price: '₺32.99',
      image: 'assets/images/d_vitamin.png',
      category: 'Sağlık',
    ),
    Product(
      name: 'Kolajen',
      price: '₺129.99',
      image: 'assets/images/kolajen.webp',
      category: 'Sağlık',
    ),
    Product(
      name: 'Kreatin',
      price: '₺78.99',
      image: 'assets/images/kreatin.png',
      category: 'Spor',
    ),
    Product(
      name: 'Protein Tozu',
      price: '₺156.99',
      image: 'assets/images/protein_tozu.webp',
      category: 'Spor',
    ),
    Product(
      name: 'Saç Serum',
      price: '₺67.99',
      image: 'assets/images/sac_serum.jpg',
      category: 'Saç Bakımı',
    ),
    Product(
      name: 'Spor Tayt',
      price: '₺89.99',
      image: 'assets/images/spor_tayt.webp',
      category: 'Spor Giyim',
    ),
    Product(
      name: 'Yoga Mat',
      price: '₺124.99',
      image: 'assets/images/yoga_mat.webp',
      category: 'Spor',
    ),
  ];

  final List<BannerData> _banners = [
    BannerData(
      title: 'Sağlıklı Yaşam İçin\nDews Store\'da Alışveriş Yapın!',
      subtitle: 'Tüm ürünlerde %20 indirim',
      color1: const Color(0xFF2E7D32),
      color2: const Color(0xFF4CAF50),
    ),
    BannerData(
      title: 'Yeni Spor Ürünleri\nGeldi!',
      subtitle: 'Protein tozu ve kreatin fırsatları',
      color1: const Color(0xFF1976D2),
      color2: const Color(0xFF42A5F5),
    ),
    BannerData(
      title: 'Cilt Bakım Setleri\nÖzel Fiyatlarla',
      subtitle: 'Maskeler ve serumlar',
      color1: const Color(0xFFE91E63),
      color2: const Color(0xFFF48FB1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products;
    _bannerController = PageController();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentBannerIndex < _banners.length - 1) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerTimer();
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      if (category == 'Tümü') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product.category == category;
        }).toList();
      }
    });
  }

  List<Product> _getProductsByCategory(String category) {
    if (category == 'Tümü') {
      return _products.take(4).toList(); // İlk 4 ürünü göster
    }
    return _products.where((product) => product.category == category).toList();
  }

  void _addToCart(Product product) {
    setState(() {
      // Ürün zaten sepette var mı kontrol et
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.name == product.name,
      );

      if (existingIndex != -1) {
        // Ürün zaten sepette varsa miktarını artır
        _cartItems[existingIndex].quantity++;
      } else {
        // Yeni ürün ekle
        _cartItems.add(CartItem(product: product));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () => _removeFromCart(product),
        ),
      ),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.name == product.name);
    });
  }

  void _updateQuantity(Product product, int newQuantity) {
    setState(() {
      final item = _cartItems.firstWhere(
        (item) => item.product.name == product.name,
      );
      if (newQuantity <= 0) {
        _cartItems.remove(item);
      } else {
        item.quantity = newQuantity;
      }
    });
  }

  double get _cartTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.store, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Dews Store',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategoriler',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Sepet',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildCategoriesPage();
      case 2:
        return _buildCartPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: 'Ürün ara...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(Icons.mic, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Banner Carousel
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [banner.color1, banner.color2],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Banner indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentBannerIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Kategoriler
          const Text(
            'Kategoriler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryCard('Tümü', Icons.all_inclusive, Colors.grey),
                _buildCategoryCard(
                  'Sağlık',
                  Icons.health_and_safety,
                  Colors.green,
                ),
                _buildCategoryCard('Spor', Icons.fitness_center, Colors.blue),
                _buildCategoryCard('Cilt Bakımı', Icons.face, Colors.pink),
                _buildCategoryCard(
                  'Saç Bakımı',
                  Icons.content_cut,
                  Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Kategori bazlı ürünler
          _buildCategoryProducts(
            'Sağlık',
            Icons.health_and_safety,
            Colors.green,
          ),
          const SizedBox(height: 24),
          _buildCategoryProducts('Spor', Icons.fitness_center, Colors.blue),
          const SizedBox(height: 24),
          _buildCategoryProducts('Cilt Bakımı', Icons.face, Colors.pink),
          const SizedBox(height: 24),
          _buildCategoryProducts(
            'Saç Bakımı',
            Icons.content_cut,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              category: title,
              products: _getProductsByCategory(title),
              onAddToCart: _addToCart,
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProducts(String category, IconData icon, Color color) {
    final categoryProducts = _getProductsByCategory(category);

    if (categoryProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              category,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _filterByCategory(category),
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: categoryProducts.length > 6 ? 6 : categoryProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(categoryProducts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailPage(product: product, onAddToCart: _addToCart),
          ),
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kare ürün resmi
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Ürün bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 9),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.price,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          onPressed: () => _addToCart(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return const Center(
      child: Text('Kategoriler Sayfası', style: TextStyle(fontSize: 20)),
    );
  }

  Widget _buildCartPage() {
    if (_cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sepetiniz boş',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Alışverişe başlamak için ürün ekleyin',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Ürün resmi
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(item.product.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ürün bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.product.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₺${item.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Miktar kontrolleri
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _updateQuantity(
                                  item.product,
                                  item.quantity - 1,
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(
                                  item.product,
                                  item.quantity + 1,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromCart(item.product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Toplam ve ödeme butonu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Toplam:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₺${_cartTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cartItems.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                cartItems: _cartItems,
                                total: _cartTotal,
                                onPaymentSuccess: () {
                                  setState(() {
                                    _cartItems.clear();
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Ödeme başarıyla tamamlandı!',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ödemeye Geç',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return const Center(
      child: Text('Profil Sayfası', style: TextStyle(fontSize: 20)),
    );
  }
}

class Product {
  final String name;
  final String price;
  final String image;
  final String category;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });
}

class BannerData {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice {
    return double.parse(product.price.replaceAll('₺', '')) * quantity;
  }
}

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onPaymentSuccess;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.total,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      // Simüle edilmiş ödeme işlemi
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false;
        });
        widget.onPaymentSuccess();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sipariş özeti
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sipariş Özeti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} (${item.quantity}x)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '₺${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₺${widget.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ödeme formu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kart Bilgileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kart numarası
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Kart Numarası',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kart numarası gerekli';
                          }
                          if (value.replaceAll(' ', '').length != 16) {
                            return 'Geçerli bir kart numarası girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kart sahibi
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Kart Sahibi',
                          hintText: 'Ad Soyad',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kart sahibi adı gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Son kullanma tarihi ve CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'Son Kullanma',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Son kullanma tarihi gerekli';
                                }
                                if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                  return 'MM/YY formatında girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV gerekli';
                                }
                                if (value.length != 3) {
                                  return '3 haneli CVV girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ödeme butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('İşleniyor...'),
                        ],
                      )
                    : const Text(
                        'Ödemeyi Tamamla',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsPage extends StatelessWidget {
  final String category;
  final List<Product> products;
  final Function(Product) onAddToCart;

  const CategoryProductsPage({
    super.key,
    required this.category,
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: products.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Bu kategoride ürün bulunamadı',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(context, products[index]);
              },
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailPage(product: product, onAddToCart: onAddToCart),
          ),
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kare ürün resmi
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Ürün bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 9),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.price,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          onPressed: () => onAddToCart(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün resmi
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(widget.product.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ürün bilgileri
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.category,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Fiyat
            Row(
              children: [
                Text(
                  widget.product.price,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'Stokta',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Miktar seçimi
            Row(
              children: [
                const Text(
                  'Miktar:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ürün açıklaması
            const Text(
              'Ürün Açıklaması',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ürün sağlıklı yaşam için özel olarak seçilmiştir. '
              'Kaliteli malzemelerden üretilmiş olup, güvenle kullanabilirsiniz.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Sepete ekle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Miktar kadar sepete ekle
                  for (int i = 0; i < quantity; i++) {
                    widget.onAddToCart(widget.product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${quantity} adet ${widget.product.name} sepete eklendi!',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sepete Ekle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
