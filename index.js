const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const { instagramGetUrl } = require("instagram-url-direct");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Root route
app.get("/", (req, res) => {
  res.json({
    status: "ok",
    message: "Instagram Proxy Server is running 🚀",
    endpoint: "/api/download",
    usage: "POST { url: '<instagram_post_url>' }"
  });
});

// Main API
app.post("/api/download", async (req, res) => {
  try {
    console.log("------------------------------Received Request------------------------------");
    const { url } = req.body;

    if (!url) {
      return res.status(400).json({ error: "Instagram URL is required" });
    }

    const response = await instagramGetUrl(url);

    if (!response || !response.url_list || response.url_list.length === 0) {
      console.log("No media found for this URL");
      return res.status(404).json({ error: "No media found for this URL" });
    }

    console.log("Media found:", response);
    console.log("------------------------------End of Request------------------------------");
    res.json({ response });
  } catch (err) {
    console.error("Server error:", err.message);
    res.status(500).json({ error: err.message || "Something went wrong" });
  }
});

const PORT = process.env.PORT || 9000;
app.listen(PORT, () => {
  console.log(`✅ Instagram proxy server running on port ${PORT}`);
});
