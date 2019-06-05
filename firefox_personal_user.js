//
// Additional settings to concatenate onto a user.js file
// like from https://github.com/pyllyukko/user.js
//

user_pref("browser.aboutConfig.showWarning",   false);
user_pref("dom.webnotifications.enabled",      false);
user_pref("browser.search.suggest.enabled",    false);
user_pref("general.warnOnAboutConfig",         false);
user_pref("browser.tabs.warnOnClose",          false);
user_pref("browser.tabs.warnOnCloseOtherTabs", false);

// Overrides to stock user.js
user_pref("browser.privatebrowsing.autostart", false);
user_pref("privacy.clearOnShutdown.history",   false);
user_pref("places.history.enabled",             true);
user_pref("keyword.enabled",                    true);
user_pref("signon.rememberSignons",	            true);
user_pref("signon.autofillForms",               true);
user_pref("browser.urlbar.suggest.history",     true);
