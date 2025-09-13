# 📸 Instagram Proxy Server

A lightweight **Node.js server** that fetches Instagram post/reel media using [instagram-url-direct](https://www.npmjs.com/package/instagram-url-direct).  
You can deploy it on multiple servers (e.g., Android via Termux) and then use those servers in your main project.

---

## 🚀 Installation (on Android via Termux)

```bash
# Install Node.js & Git (if not installed)
pkg update && pkg upgrade -y
pkg install nodejs git -y

# Clone repo
git clone https://github.com/<your-username>/insta-proxy.git
cd insta-proxy

# Install dependencies
npm install

# Start server
npm start
