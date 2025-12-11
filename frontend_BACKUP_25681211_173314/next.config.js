/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  swcMinify: true,
  images: {
    domains: [
      "localhost",
      "127.0.0.1",
      "lh3.googleusercontent.com",
      "images.unsplash.com",
      "cdn.jsdelivr.net"
    ]
  }
};

module.exports = nextConfig;
