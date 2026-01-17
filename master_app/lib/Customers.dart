import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Base URL - read from .env (set `API_BASE_URL`) with a fallback
final String API_BASE_URL = "http://localhost:8000";

class Customer {
  int id;
  String name;
  String phone;
  String area;
  DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.area,
    required this.createdAt,
  });

  // Convert Customer to JSON for API requests
  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'Area': area};
  }

  // Create Customer from API response JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      area: json['area'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class CustomersPage extends StatefulWidget {
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<Customer> customers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // ============================================================
  // API METHODS - Backend HTTP calls
  // ============================================================

  /// Fetches all customers from the backend API
  Future<List<Customer>> _fetchCustomersFromDatabase() async {
    try {
      final response = await http
          .get(Uri.parse('$API_BASE_URL/customers'))
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  /// Adds a new customer via the backend API
  Future<Customer?> _addCustomerToDatabase(
    String name,
    String phone,
    String area,
  ) async {
    try {
      final response = await http.post(
            Uri.parse('$API_BASE_URL/customers'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'phone': phone, 'Area': area}),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Customer.fromJson(data);
      } else {
        throw Exception('Failed to add customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding customer: $e');
    }
  }

  /// Updates an existing customer via the backend API
  Future<bool> _updateCustomerInDatabase(Customer customer) async {
    try {
      final response = await http
          .put(
            Uri.parse('$API_BASE_URL/customers/${customer.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': customer.name,
              'phone': customer.phone,
              'address': customer.area,
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  /// Deletes a customer via the backend API
  Future<bool> _deleteCustomerFromDatabase(int customerId) async {
    try {
      final response = await http
          .delete(Uri.parse('$API_BASE_URL/customers/$customerId'))
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  // ============================================================
  // UI STATE MANAGEMENT METHODS
  // ============================================================

  /// Loads customers and updates UI state
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedCustomers = await _fetchCustomersFromDatabase();
      setState(() {
        customers = fetchedCustomers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load customers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Handles adding a new customer
  Future<void> _handleAddCustomer(
    String name,
    String phone,
    String area,
  ) async {
    try {
      final newCustomer = await _addCustomerToDatabase(name, phone, area);
      if (newCustomer != null) {
        setState(() {
          customers.add(newCustomer);
        });
        return;
      }
      throw Exception('Failed to create customer');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding customer: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Handles updating an existing customer
  Future<void> _handleUpdateCustomer(
    int index,
    Customer updatedCustomer,
  ) async {
    try {
      final success = await _updateCustomerInDatabase(updatedCustomer);
      if (success) {
        setState(() {
          customers[index] = updatedCustomer;
        });
        return;
      }
      throw Exception('Failed to update customer');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating customer: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Handles deleting a customer
  Future<void> _handleDeleteCustomer(int index) async {
    try {
      final success = await _deleteCustomerFromDatabase(customers[index].id);
      if (success) {
        setState(() {
          customers.removeAt(index);
        });
        return;
      }
      throw Exception('Failed to delete customer');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting customer: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddCustomerBottomSheet({Customer? customer, int? index}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final areaController = TextEditingController(text: customer?.area ?? '');
    final isEditing = customer != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Customer' : 'Add New Customer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isEditing
                      ? 'Update customer information'
                      : 'Enter customer details below',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                SizedBox(height: 24),
                _buildTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  hint: 'Enter customer name',
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  hint: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: areaController,
                  label: 'Area of Work',
                  icon: Icons.location_on_outlined,
                  hint: 'Enter area or district',
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          phoneController.text.isNotEmpty &&
                          areaController.text.isNotEmpty) {
                        Navigator.pop(context);

                        if (isEditing && index != null) {
                          final updatedCustomer = Customer(
                            id: customer.id,
                            name: nameController.text,
                            phone: phoneController.text,
                            area: areaController.text,
                            createdAt: DateTime.now()
                          );
                          await _handleUpdateCustomer(index, updatedCustomer);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Customer updated successfully!'),
                              backgroundColor: Colors.green[600],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else {
                          await _handleAddCustomer(
                            nameController.text,
                            phoneController.text,
                            areaController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Customer added successfully!'),
                              backgroundColor: Colors.green[600],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Update Customer' : 'Add Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Color(0xFF4F46E5)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _deleteCustomer(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customers[index].name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteCustomer(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Customer deleted successfully!'),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getIdColor(int index) {
    List<Color> colors = [
      Color(0xFFE53935), // Red
      Color(0xFF8E24AA), // Purple
      Color(0xFF43A047), // Green
      Color(0xFFFB8C00), // Orange
      Color(0xFF1E88E5), // Blue
      Color(0xFF00ACC1), // Cyan
      Color(0xFF3949AB), // Indigo
      Color(0xFFD81B60), // Pink
    ];
    return colors[index % colors.length];
  }

  // ============================================================
  // UI STATE WIDGETS
  // ============================================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading customers...',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An error occurred while loading customers',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCustomers,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('Try Again', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No customers yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first customer',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: customers.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 24,
        endIndent: 24,
        color: Colors.grey[200],
      ),
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Customer ID Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIdColor(index).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      customer.id.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getIdColor(index),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Customer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              customer.area,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4),
                          Text(
                            customer.phone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showAddCustomerBottomSheet(
                        customer: customer,
                        index: index,
                      ),
                      icon: Icon(Icons.edit_outlined),
                      iconSize: 20,
                      color: Color(0xFF4F46E5),
                      splashRadius: 24,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteCustomer(index),
                      icon: Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: Colors.red[400],
                      splashRadius: 24,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customers',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage and view all your customers',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  // Refresh button
                  IconButton(
                    onPressed: _loadCustomers,
                    icon: Icon(Icons.refresh),
                    color: Color(0xFF4F46E5),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            // Customer List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                  ? _buildErrorState()
                  : customers.isEmpty
                  ? _buildEmptyState()
                  : _buildCustomerList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerBottomSheet(),
        backgroundColor: Color(0xFF4F46E5),
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
