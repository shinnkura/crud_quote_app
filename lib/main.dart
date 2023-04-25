import 'package:flutter/material.dart';
import 'quote_database.dart';
import 'quote.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(QuotesApp());
}

class QuotesApp extends StatelessWidget {
  const QuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuotesList(),
    );
  }
}

class QuotesList extends StatefulWidget {
  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  List<Quote> quotesList = [];

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  fetchQuotes() async {
    List<Quote> quotes = await QuoteDatabase.instance.readAllQuotes();
    setState(() {
      quotesList = quotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotes'),
      ),
      body: ListView.builder(
        itemCount: quotesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(quotesList[index].text),
            subtitle: Text(quotesList[index].author),
            onTap: () => _showDialog(context, quote: quotesList[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDialog(BuildContext context, {Quote? quote}) {
    final _formKey = GlobalKey<FormState>();
    final _quoteTextController = TextEditingController(text: quote?.text ?? '');
    final _quoteAuthorController =
        TextEditingController(text: quote?.author ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(quote == null ? 'Add Quote' : 'Update Quote'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _quoteTextController,
                  decoration: InputDecoration(labelText: 'Quote'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quote';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quoteAuthorController,
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (quote == null) {
                    // Create a new quote
                    await QuoteDatabase.instance.create(
                      Quote(
                        text: _quoteTextController.text,
                        author: _quoteAuthorController.text,
                      ),
                    );
                  } else {
                    // Update the existing quote
                    await QuoteDatabase.instance.update(
                      quote.copyWith(
                        text: _quoteTextController.text,
                        author: _quoteAuthorController.text,
                      ),
                    );
                  }
                  fetchQuotes();
                  Navigator.of(context).pop();
                }
              },
              child: Text(quote == null ? 'Add' : 'Update'),
            ),
            if (quote != null)
              TextButton(
                onPressed: () async {
                  await QuoteDatabase.instance.delete(quote.id!);
                  fetchQuotes();
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
              ),
          ],
        );
      },
    );
  }
}
