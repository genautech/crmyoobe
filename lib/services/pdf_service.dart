import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets' as pw;
import 'package:intl/intl.dart';
import '../models/production_order.dart';
import '../models/supplier.dart';

class PdfService {
  static Future<Uint8List> generateProductionOrderPdf(
    ProductionOrder order,
    Supplier? supplier,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Load Yoobe logo
    final logoData = await rootBundle.load('assets/images/yoobe_logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header with Logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ORDEM DE PRODUÇÃO',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      order.productionOrderNumber,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Brindes Promocionais',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2, color: PdfColors.indigo900),
            pw.SizedBox(height: 20),

            // Information Grid
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column - Customer Info
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CLIENTE',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _buildInfoRow('Nome', order.customerName),
                        if (order.customerCompany.isNotEmpty)
                          _buildInfoRow('Empresa', order.customerCompany),
                        if (order.campaignName.isNotEmpty)
                          _buildInfoRow('Campanha', order.campaignName),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                
                // Right Column - Supplier Info
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PRODUTOR',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (supplier != null) ...[
                          _buildInfoRow('Nome', supplier.name),
                          if (supplier.company.isNotEmpty)
                            _buildInfoRow('Empresa', supplier.company),
                          if (supplier.phone.isNotEmpty)
                            _buildInfoRow('Telefone', supplier.phone),
                          if (supplier.email.isNotEmpty)
                            _buildInfoRow('E-mail', supplier.email),
                        ] else
                          _buildInfoRow('Nome', order.supplierName),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Dates and Status
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildDateBox('Data de Criação', dateFormat.format(order.productionDate)),
                  if (order.deliveryDeadline != null)
                    _buildDateBox('Prazo de Entrega', dateFormat.format(order.deliveryDeadline!)),
                  _buildStatusBox(order.productionStatus.displayName),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Items Table
            pw.Text(
              'ITENS DA PRODUÇÃO',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                  children: [
                    _buildTableCell('PRODUTO', isHeader: true),
                    _buildTableCell('QTD', isHeader: true),
                    _buildTableCell('PREÇO UNIT.', isHeader: true),
                    _buildTableCell('TOTAL', isHeader: true),
                  ],
                ),
                // Data Rows
                ...order.items.map((item) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(item.productName),
                      _buildTableCell(item.quantity.toString(), align: pw.TextAlign.center),
                      _buildTableCell(currencyFormat.format(item.price), align: pw.TextAlign.right),
                      _buildTableCell(currencyFormat.format(item.total), align: pw.TextAlign.right),
                    ],
                  );
                }),
                // Total Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('', colspan: 3),
                    _buildTableCell(
                      currencyFormat.format(order.totalAmount),
                      isBold: true,
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Delivery Address
            if (order.dispatchAddress.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ENDEREÇO DE ENTREGA',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(order.dispatchAddress, style: const pw.TextStyle(fontSize: 11)),
                    if (order.dispatchCity.isNotEmpty || order.dispatchState.isNotEmpty)
                      pw.Text(
                        '${order.dispatchCity}${order.dispatchCity.isNotEmpty && order.dispatchState.isNotEmpty ? ', ' : ''}${order.dispatchState}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    if (order.dispatchZipCode.isNotEmpty)
                      pw.Text('CEP: ${order.dispatchZipCode}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // Notes
            if (order.notes.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border.all(color: PdfColors.amber200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'OBSERVAÇÕES',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber900,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(order.notes, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // Payment Info (if supplier has bank details)
            if (supplier != null && (supplier.bankName.isNotEmpty || supplier.pixKey.isNotEmpty)) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DADOS PARA PAGAMENTO',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (supplier.bankName.isNotEmpty)
                      _buildInfoRow('Banco', supplier.bankName),
                    if (supplier.bankAccount.isNotEmpty)
                      _buildInfoRow('Conta/Agência', supplier.bankAccount),
                    if (supplier.pixKey.isNotEmpty)
                      _buildInfoRow('Chave PIX', supplier.pixKey),
                    if (supplier.paymentTerms.isNotEmpty)
                      _buildInfoRow('Condições', supplier.paymentTerms),
                  ],
                ),
              ),
            ],

            // Signature Section
            pw.SizedBox(height: 32),
            pw.Divider(thickness: 1.5, color: PdfColors.grey300),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Yoobe Signature
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 60,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'YOOBE CRM',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Responsável',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Data: ${dateFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 24),
                
                // Supplier Signature
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 60,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        supplier != null ? supplier.name.toUpperCase() : order.supplierName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Produtor',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Data: ___/___/______',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Footer
            pw.Spacer(),
            pw.Divider(thickness: 2, color: PdfColors.indigo900),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Yoobe - Brindes Promocionais',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                    ),
                    pw.Text(
                      'Sistema de Gestão de Produção',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Documento gerado em:',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDateBox(String label, String date) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          date,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildStatusBox(String status) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo900,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        status,
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    int colspan = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 10,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: align,
      ),
    );
  }
}
