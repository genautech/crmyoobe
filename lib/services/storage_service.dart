import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/task.dart';
import '../models/order.dart';
import '../models/quote.dart';
import '../models/product.dart';
import '../models/production_order.dart';

class StorageService {
  static const String customersBox = 'customers';
  static const String tasksBox = 'tasks';
  static const String ordersBox = 'orders';
  static const String quotesBox = 'quotes';
  static const String productsBox = 'products';
  static const String productionOrdersBox = 'productionOrders';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (IDs must match @HiveType typeId)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(QuoteItemAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(QuoteAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ProductionOrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ProductionOrderAdapter());
    }
    // New typeIds for updated models (avoid conflicts with old data)
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(OrderAdapter());
    }

    // Open boxes with error handling for corrupted data
    await Hive.openBox<Customer>(customersBox);
    await Hive.openBox<Task>(tasksBox);
    await Hive.openBox<Quote>(quotesBox);
    await Hive.openBox<Product>(productsBox);
    await Hive.openBox<ProductionOrder>(productionOrdersBox);
    
    // Orders box needs special handling due to schema migration
    try {
      await Hive.openBox<Order>(ordersBox);
    } catch (e) {
      // If orders box is corrupted, delete and recreate
      await Hive.deleteBoxFromDisk(ordersBox);
      await Hive.openBox<Order>(ordersBox);
    }

    // Initialize with sample data if empty
    await _initializeSampleData();
  }

  static Future<void> _initializeSampleData() async {
    final customersBoxInstance = Hive.box<Customer>(customersBox);
    final productsBoxInstance = Hive.box<Product>(productsBox);

    // Add sample customers if empty
    if (customersBoxInstance.isEmpty) {
      final sampleCustomers = [
        Customer(
          id: 'c1',
          name: 'João Silva',
          email: 'joao.silva@example.com',
          phone: '(11) 98765-4321',
          company: 'Silva Comércio Ltda',
          address: 'Rua das Flores, 123 - São Paulo, SP',
          notes: 'Cliente preferencial, solicita entregas aos sábados',
        ),
        Customer(
          id: 'c2',
          name: 'Maria Santos',
          email: 'maria.santos@example.com',
          phone: '(21) 99876-5432',
          company: 'Santos Indústria',
          address: 'Av. Brasil, 456 - Rio de Janeiro, RJ',
          notes: 'Compras mensais de grande volume',
        ),
        Customer(
          id: 'c3',
          name: 'Pedro Costa',
          email: 'pedro.costa@example.com',
          phone: '(31) 97654-3210',
          company: 'Costa Distribuidora',
          address: 'Rua da Bahia, 789 - Belo Horizonte, MG',
          notes: 'Solicita orçamentos detalhados',
        ),
      ];

      for (var customer in sampleCustomers) {
        await customersBoxInstance.put(customer.id, customer);
      }
    }

    // Add sample products if empty
    if (productsBoxInstance.isEmpty) {
      final sampleProducts = [
        Product(
          id: 'p1',
          name: 'Camiseta Básica Premium',
          description: 'Camiseta 100% algodão de alta qualidade, perfeita para personalização. Gola careca reforçada, corte reto unissex. Ideal para eventos, uniformes e brindes corporativos.',
          category: 'Camisetas',
          price: 35.90,
          sku: 'CAM-BAS-001',
          stock: 150,
          imageUrl: 'https://via.placeholder.com/300x400/FFFFFF/000000?text=Camiseta+Branca',
          brand: 'Malwee',
          colors: ['Branco', 'Preto', 'Azul', 'Vermelho', 'Verde'],
          sizes: ['PP', 'P', 'M', 'G', 'GG', 'XG'],
          material: '100% Algodão Penteado',
          weight: 0.2,
          dimensions: '30x40cm (dobrada)',
          minimumOrderQuantity: 10,
          costPrice: 18.50,
          supplier: 'Distribuidora Têxtil Sul',
          leadTimeDays: 5,
          printingArea: 'Frente: 30x40cm, Costa: 35x45cm',
          printingMethods: ['Serigrafia', 'Sublimação', 'Transfer'],
          origin: 'Brasil',
        ),
        Product(
          id: 'p2',
          name: 'Boné Trucker Personalizado',
          description: 'Boné estilo trucker com tela traseira, aba curva e ajuste de tamanho. Frontal em espuma alta densidade para sublimação ou bordado. Perfeito para eventos ao ar livre.',
          category: 'Bonés e Chapéus',
          price: 28.90,
          sku: 'BON-TRU-002',
          stock: 200,
          imageUrl: 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Bone+Trucker',
          brand: 'New Era',
          colors: ['Preto', 'Branco', 'Azul', 'Vermelho'],
          sizes: ['Único'],
          material: 'Frontal: Espuma, Traseiro: Tela de Poliéster',
          weight: 0.08,
          dimensions: 'Circunferência: 56-62cm',
          minimumOrderQuantity: 20,
          costPrice: 14.50,
          supplier: 'Caps & Co',
          leadTimeDays: 7,
          printingArea: 'Frontal: 12x8cm',
          printingMethods: ['Bordado', 'Sublimação', 'Transfer'],
          origin: 'Brasil',
        ),
        Product(
          id: 'p3',
          name: 'Caneca Cerâmica 325ml',
          description: 'Caneca em cerâmica branca AAA de alta qualidade, própria para sublimação. Alça confortável e acabamento perfeito. Resistente a micro-ondas e lava-louças.',
          category: 'Canecas',
          price: 12.90,
          sku: 'CAN-CER-003',
          stock: 500,
          imageUrl: 'https://via.placeholder.com/300x300/FFFFFF/000000?text=Caneca+Branca',
          brand: 'Cerâmica Brasil',
          colors: ['Branco'],
          sizes: ['325ml'],
          material: 'Cerâmica AAA',
          weight: 0.35,
          dimensions: '8cm diâmetro x 9.5cm altura',
          minimumOrderQuantity: 24,
          costPrice: 6.50,
          supplier: 'Cerâmica Paulista',
          leadTimeDays: 3,
          printingArea: '360° (área completa)',
          printingMethods: ['Sublimação'],
          origin: 'Brasil',
        ),
        Product(
          id: 'p4',
          name: 'Garrafa Squeeze 500ml',
          description: 'Squeeze em alumínio com pintura epóxi, tampa rosqueável com bico retrátil. Livre de BPA, leve e resistente. Perfeito para academias, ciclismo e eventos esportivos.',
          category: 'Garrafas e Squeezes',
          price: 24.90,
          sku: 'GAR-SQU-004',
          stock: 180,
          imageUrl: 'https://via.placeholder.com/200x400/4169E1/FFFFFF?text=Squeeze+Azul',
          brand: 'Mor',
          colors: ['Azul', 'Vermelho', 'Verde', 'Preto', 'Branco'],
          sizes: ['500ml'],
          material: 'Alumínio com pintura epóxi',
          weight: 0.12,
          dimensions: '6.5cm diâmetro x 22cm altura',
          minimumOrderQuantity: 25,
          costPrice: 12.90,
          supplier: 'Plasutil Distribuidora',
          leadTimeDays: 10,
          printingArea: '8cm x 15cm (lateral)',
          printingMethods: ['Laser', 'Serigrafia'],
          origin: 'Brasil',
        ),
        Product(
          id: 'p5',
          name: 'Mochila Saco Personalizada',
          description: 'Mochila saco em TNT 80g/m², cordão em nylon resistente. Design versátil e econômico, ideal para eventos, feiras e brindes promocionais em grande quantidade.',
          category: 'Mochilas e Bolsas',
          price: 8.90,
          sku: 'MOC-SAC-005',
          stock: 1000,
          imageUrl: 'https://via.placeholder.com/300x400/32CD32/FFFFFF?text=Mochila+Verde',
          brand: 'Sacolas BR',
          colors: ['Verde', 'Azul', 'Vermelho', 'Amarelo', 'Preto', 'Branco'],
          sizes: ['35x40cm'],
          material: 'TNT 80g/m²',
          weight: 0.05,
          dimensions: '35cm x 40cm',
          minimumOrderQuantity: 100,
          costPrice: 3.90,
          supplier: 'TNT Brindes',
          leadTimeDays: 15,
          printingArea: '25cm x 30cm (frente)',
          printingMethods: ['Serigrafia'],
          origin: 'Brasil',
        ),
        Product(
          id: 'p6',
          name: 'Caneta Metálica Touch',
          description: 'Caneta esferográfica em metal com ponta touch para telas capacitivas. Acabamento premium com detalhes cromados. Clip de bolso reforçado. Carga azul substituível.',
          category: 'Canetas e Lápis',
          price: 15.90,
          sku: 'CAN-MET-006',
          stock: 300,
          imageUrl: 'https://via.placeholder.com/150x300/C0C0C0/000000?text=Caneta+Metal',
          brand: 'Parker Style',
          colors: ['Prata', 'Preto', 'Azul', 'Vermelho'],
          sizes: ['Único'],
          material: 'Metal cromado',
          weight: 0.03,
          dimensions: '1cm diâmetro x 14cm comprimento',
          minimumOrderQuantity: 50,
          costPrice: 7.90,
          supplier: 'Canetas Premium',
          leadTimeDays: 12,
          printingArea: '5cm x 0.8cm (corpo)',
          printingMethods: ['Laser', 'Tampografia'],
          origin: 'China',
        ),
      ];

      for (var product in sampleProducts) {
        await productsBoxInstance.put(product.id, product);
      }
    }
  }

  // Box getters
  static Box<Customer> getCustomersBox() => Hive.box<Customer>(customersBox);
  static Box<Task> getTasksBox() => Hive.box<Task>(tasksBox);
  static Box<Order> getOrdersBox() => Hive.box<Order>(ordersBox);
  static Box<Quote> getQuotesBox() => Hive.box<Quote>(quotesBox);
  static Box<Product> getProductsBox() => Hive.box<Product>(productsBox);
  static Future<Box<ProductionOrder>> getProductionOrderBox() async {
    if (Hive.isBoxOpen(productionOrdersBox)) {
      return Hive.box<ProductionOrder>(productionOrdersBox);
    }
    return await Hive.openBox<ProductionOrder>(productionOrdersBox);
  }
}
