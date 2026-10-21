# Focus 168 setup

Focus 168 is one web page (`index.html`). Accounts and saved plans are handled by **Supabase**, a hosted database with built-in sign-up and log-in. The page itself goes on **Netlify**, which gives you a link to send your friends. Both have free plans that easily cover a few people.

What's in this folder:

| File | What it is |
| --- | --- |
| `index.html` | The app. The only file that has to go online. |
| `setup.sql` | Creates the database table and the rules that keep each person's plan private. |
| `favicon.svg` | The browser-tab icon (the clock from the logo). |
| `netlify.toml` | Tells Netlify to publish the folder as-is, with no build step. |
| `serve.ps1` | Runs the app on your computer at `http://localhost:8168` for testing. |
| `SETUP.md` | This guide. |

---

## 1. Create a Supabase project

1. Go to [supabase.com](https://supabase.com), sign up, and choose **New project**.
2. Name it `Focus 168`, pick the region closest to you, and set a database password. Save the password somewhere safe. The app doesn't need it, but you'll need it to manage the database.
3. Wait a minute or two while the project starts.

## 2. Create the plans table

1. In your project, open **SQL Editor** and choose **New query**.
2. Open `setup.sql` from this folder, copy all of it, paste it in, and click **Run**.
3. You should see "Success. No rows returned."

## 3. Connect the app to your project

1. In Supabase, click **Connect** at the top of the project, or go to **Project Settings → API Keys**.
2. Copy the **Project URL** (looks like `https://abcdefgh.supabase.co`).
3. Copy the **Publishable key** (starts with `sb_publishable_`). On older projects this is the **anon public** key. Either works.
4. Open `index.html` in a text editor (Notepad is fine). Near the top, replace the two placeholder values:

   ```js
   window.FOCUS168_CONFIG = {
     supabaseUrl: "https://abcdefgh.supabase.co",
     supabaseKey: "sb_publishable_...",
   };
   ```

5. Save the file.

> **Never paste the secret key** (`sb_secret_...`, or the old `service_role` key) into the app. The publishable key is designed to be public. The rules from `setup.sql` stop anyone from reading or changing someone else's plan.

## 4. Try it on your computer

1. In this folder, right-click `serve.ps1` and choose **Run with PowerShell**. Or run this in a terminal:

   ```bash
   powershell -ExecutionPolicy Bypass -File serve.ps1
   ```

2. Open `http://localhost:8168` in your browser.
3. In Supabase, go to **Authentication → URL Configuration**. Set **Site URL** to `http://localhost:8168`, and add `http://localhost:8168` under **Redirect URLs**. This makes the links in confirmation and password-reset emails come back to the app.
4. Sign up with your own email, click the link in the confirmation email, and you're in.

## 5. Put it online

1. Go to [app.netlify.com/drop](https://app.netlify.com/drop) and sign up or log in.
2. Drag this whole `Focus` folder onto the page. Nothing in it is secret.
3. Netlify gives you a link like `https://random-name-123.netlify.app`. To get a nicer one, go to **Site configuration → Change site name**, for example `focus168`.
4. Back in Supabase, under **Authentication → URL Configuration**:
   - Change **Site URL** to your Netlify link.
   - Add your Netlify link under **Redirect URLs**. Keep the localhost one if you still want to test locally.
5. Send the link to your friends. Each person signs up with their own email and gets their own private plan.

**Updating the app later:** the Netlify project is linked to the GitHub repository `servantproductions/focus-168`. Every push to the `main` branch goes live automatically within about a minute. Nobody's account or plan is affected, because those live in Supabase.

---

## Good to know

- **Email limits.** Supabase's built-in email sender only sends a few emails per hour, which is enough for a few friends signing up. If someone doesn't get their email, wait a bit and use **Forgot your password?** or sign up again. For more volume, add your own email provider under **Authentication → Emails → SMTP settings**.
- **Skipping email confirmation.** To let people in right after signing up, turn off **Confirm email** under **Authentication → Sign In / Providers → Email**. Anyone with the link can create an account either way.
- **Who signed up.** **Authentication → Users** lists every account. To remove someone, delete them there; their plan is deleted with them.
- **Idle projects pause.** Supabase pauses free projects that go unused for about a week. If the app says it can't load or save, open the Supabase dashboard and restore the project.
- **Before you connect Supabase.** Until the two values in step 3 are filled in, the app shows "Accounts aren't connected yet" and offers **Try it without an account**, which saves to that browser only.
