import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/sse_cubit.dart';
import 'sse_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSE Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                hintText: 'Enter your user ID',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Connect to SSE'),
              onPressed: () {
                final userId = _userIdController.text.trim();
                if (userId.isEmpty) {
                  // Show error if no ID entered
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a user ID')),
                  );
                  return;
                }

                // Initiate SSE connection and move to next screen
                _connectAndNavigate(context, userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _connectAndNavigate(BuildContext context, String userId) {
    // Start the SSE connection
    context.read<SseCubit>().connectSSE(userId);

    // Navigate to SSEScreen and listen for disconnect/session-end events
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocListener<SseCubit, SseState>(
              listener: (context, state) {
                if (state is SseDisconnected) {
                  _showMessageAndPop(context, 'Disconnected from server');
                } else if (state is SseSessionEnded) {
                  _showMessageAndPop(context, state.message);
                }
              },
              child: SSEScreen(),
            ),
      ),
    );
  }

  void _showMessageAndPop(BuildContext context, String message) {
    // Return to login screen
    Navigator.pop(context);

    // Show result of disconnection or session end
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
