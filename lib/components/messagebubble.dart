import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gudalur/screens/chat_image_screen.dart';
 
class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe, this.isImage, this.time});
  final String sender;
  final String text;
  final bool isMe;
  final bool isImage;
  final String time;
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Color.fromRGBO(61, 90, 241, 1),
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            
            ),
          ),
          SizedBox(height: 5),
          Material(
            color: isMe
                ? Color.fromRGBO(61, 90, 241, 1)
                : Color(0xFFF1F2F6),
                borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                    topRight: Radius.circular(5.0),
                  ),
            child: Padding(
              padding: !isImage
                  ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0)
                  : EdgeInsets.all(5),
              child: !isImage
                  ? Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 18.0,
                      ),
                    )
                  : GestureDetector(
                      onDoubleTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatImageScreen(
                                url: text,
                                name: sender
                              ),
                            ));
                      },
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueAccent),
                              ),
                            ),
                            width: 200,
                            height: 200,
                          ),
                          errorWidget: (context, url, error) => Material(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            child: Image.asset(
                              'assets/photos/notavailable.png',
                              width: 200,
                              height: 200,
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: text,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Poppins',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
