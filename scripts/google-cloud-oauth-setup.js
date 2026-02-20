// Google Cloud Console OAuth Configuration Guide
// This script opens Google Cloud Console and helps you configure OAuth settings

const { chromium } = require('playwright');

const CLIENT_ID = '879598092731-sn5unu43moo46vveb1gkeb002fdvaknt';
const OLD_REDIRECT_URI = 'com.taurai.ledger://oauth/callback';
const NEW_REDIRECT_URI = 'com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth';
const BUNDLE_ID = 'taurai.ledger';

async function setupGoogleCloudOAuth() {
  console.log('🚀 Google Cloud OAuth Configuration Helper');
  console.log('==========================================\n');

  const browser = await chromium.launch({
    headless: false,
    slowMo: 1000 // Slow down actions for visibility
  });

  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('📝 Step 1: Opening Google Cloud Console...');
    await page.goto('https://console.cloud.google.com/apis/credentials');

    console.log('\n⏳ Waiting for you to sign in to Google Cloud Console...');
    console.log('   Please sign in with your Google account if prompted.\n');

    // Wait for the user to sign in and the credentials page to load
    await page.waitForURL('**/apis/credentials**', { timeout: 120000 });

    console.log('✅ Signed in successfully!\n');

    console.log('📝 Step 2: Looking for your OAuth Client...');
    console.log(`   Client ID: ${CLIENT_ID}\n`);

    // Give user time to see the page
    await page.waitForTimeout(2000);

    console.log('📋 MANUAL INSTRUCTIONS:');
    console.log('=======================\n');

    console.log('1. Find your OAuth 2.0 Client ID in the list:');
    console.log(`   Look for: ${CLIENT_ID}`);
    console.log('   (It should be under "OAuth 2.0 Client IDs" section)\n');

    console.log('2. Click the EDIT icon (pencil) next to your client\n');

    console.log('3. Scroll down to "Authorized redirect URIs"\n');

    console.log('4. REMOVE the old deprecated redirect URI:');
    console.log(`   ❌ ${OLD_REDIRECT_URI}\n`);

    console.log('5. ADD the new SDK-compatible redirect URI:');
    console.log(`   ✅ ${NEW_REDIRECT_URI}`);
    console.log('   (Click "+ ADD URI" button, paste this exactly)\n');

    console.log('6. Verify Application Type:');
    console.log('   Should be: iOS\n');

    console.log('7. Verify Bundle ID:');
    console.log(`   Should be: ${BUNDLE_ID}\n`);

    console.log('8. Click SAVE at the bottom\n');

    console.log('═══════════════════════════════════════════\n');

    // Highlight the redirect URI that needs to be added
    console.log('💡 TIP: Copy this redirect URI to your clipboard:');
    console.log('─────────────────────────────────────────────');
    console.log(NEW_REDIRECT_URI);
    console.log('─────────────────────────────────────────────\n');

    console.log('📍 Additional Setup Steps:');
    console.log('=========================\n');

    console.log('After updating OAuth client, also verify:\n');

    console.log('✓ Gmail API is enabled:');
    console.log('  Go to: APIs & Services → Library');
    console.log('  Search: Gmail API');
    console.log('  Status should show: "API enabled"\n');

    console.log('✓ Test users are added (if in Testing mode):');
    console.log('  Go to: APIs & Services → OAuth consent screen');
    console.log('  If status is "Testing", add your test Gmail addresses\n');

    console.log('⏳ Browser will stay open for you to complete these steps.');
    console.log('   Press Ctrl+C in terminal when done.\n');

    // Keep browser open
    await new Promise(() => {});

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.log('\n💡 Common issues:');
    console.log('   - Make sure you have access to the Google Cloud project');
    console.log('   - Verify you\'re signed in with the correct Google account');
    console.log('   - Check if the project ID is correct');
  } finally {
    // Don't close browser automatically - let user do it
    console.log('\n✅ You can close this browser when done.');
  }
}

// Run the setup
setupGoogleCloudOAuth().catch(console.error);
