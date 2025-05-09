import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/sse_cubit.dart';

class SSEScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSE Connection'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: BlocBuilder<SseCubit, SseState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildConnectionStatus(state),
                const SizedBox(height: 20),
                if (state is SseConnected) _buildMessageDisplay(state),
                const Spacer(),
                ElevatedButton(
                  child: const Text('Disconnect'),
                  onPressed: () {
                    context.read<SseCubit>().disconnect();
                    // Navigation is handled by the listener in LoginScreen
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(SseState state) {
    Color color;
    String status;

    if (state is SseConnected) {
      color = Colors.green;
      status = 'CONNECTED';
    } else if (state is SseConnecting) {
      color = Colors.orange;
      status = 'CONNECTING...';
    } else {
      color = Colors.red;
      status = 'DISCONNECTED';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: color,
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Text(status, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMessageDisplay(SseConnected state) {
    return Expanded(
      child: ListView.builder(
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          return Card(child: ListTile(title: Text(state.messages[index])));
        },
      ),
    );
  }
}
