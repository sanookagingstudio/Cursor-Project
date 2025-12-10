import fetch from "node-fetch";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_KEY;
const adminEmail = process.env.ADMIN_EMAIL;
const adminPassword = process.env.ADMIN_PASSWORD;

async function run() {
  try {
    console.log("Checking existing admin user...");

    let res = await fetch(
      url + "/auth/v1/admin/users?email=" + encodeURIComponent(adminEmail),
      {
        headers: {
          apikey: serviceKey,
          Authorization: "Bearer " + serviceKey,
        },
      }
    );

    const data = await res.json();

    if (Array.isArray(data) && data.length > 0) {
      console.log("Admin already exists:", data[0].id);
      return;
    }

    console.log("Creating new admin user...");
    res = await fetch(url + "/auth/v1/admin/users", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: serviceKey,
        Authorization: "Bearer " + serviceKey,
      },
      body: JSON.stringify({
        email: adminEmail,
        password: adminPassword,
        email_confirm: true,
        user_metadata: { role: "admin" },
        app_metadata: { role: "admin" },
      }),
    });

    const result = await res.json();
    console.log("Result:", result);

  } catch (err) {
    console.error("ERROR:", err);
    process.exit(1);
  }
}

run();
