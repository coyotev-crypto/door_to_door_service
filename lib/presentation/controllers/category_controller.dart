import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

/// 分类控制器
class CategoryController extends GetxController {
  static CategoryController get to => Get.find();

  final CategoryRepository _categoryRepository = CategoryRepository();

  // 分类列表
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;

  // 当前选中的分类
  final Rx<CategoryModel?> _selectedCategory = Rx<CategoryModel?>(null);

  // 是否正在加载
  final RxBool _isLoading = false.obs;

  // 错误信息
  final RxString _errorMessage = ''.obs;

  /// 分类列表
  List<CategoryModel> get categories => _categories;

  /// 当前选中的分类
  CategoryModel? get selectedCategory => _selectedCategory.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 错误信息
  String? get errorMessage =>
      _errorMessage.value.isEmpty ? null : _errorMessage.value;

  /// 加载分类
  Future<void> loadCategories() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await _categoryRepository.getPrimaryCategories();
      _categories.value = response.list ?? [];

      // 如果有分类且没有选中项，默认选中第一个
      if (_categories.isNotEmpty && _selectedCategory.value == null) {
        _selectedCategory.value = _categories.first;
      }

      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value = e.toString();
      _categories.clear();
      _selectedCategory.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 选择分类
  /// [category] 要选择的分类
  void selectCategory(CategoryModel category) {
    _selectedCategory.value = category;
  }
}
