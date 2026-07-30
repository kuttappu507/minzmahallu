#include "I18N.h"
#include "Config.h"
#include "Logger.h"
#include <QFont>

namespace mms {

I18N& I18N::instance() { static I18N inst; return inst; }
I18N::I18N() { initTranslations(); }

void I18N::initTranslations() {
    #define ADD(key, en, ml) do { translations_[key]["en"] = en; translations_[key]["ml"] = ml; } while(0)

    ADD("app_name","Minz Mahallu Management","മിൻസ് മഹല്ല് മാനേജ്മെന്റ്");
    ADD("app_subtitle","Mosque Community Administration","മസ്ജിദ് കമ്മ്യൂണിറ്റി ഭരണം");
    ADD("login_title","Sign In","സൈൻ ഇൻ");
    ADD("login_username","Username","ഉപയോക്തൃനാമം");
    ADD("login_password","Password","രഹസ്യവാക്ക്");
    ADD("login_button","Login","ലോഗിൻ");
    ADD("login_forgot","Forgot password?","രഹസ്യവാക്ക് മറന്നോ?");
    ADD("login_default_hint","Default: admin / admin123","സ്ഥിരസ്ഥിതി: admin / admin123");
    ADD("login_error_empty","Please enter both username and password.","ദയവായി ഉപയോക്തൃനാമവും രഹസ്യവാക്കും നൽകുക.");
    ADD("login_signing_in","Signing in...","സൈൻ ഇൻ ചെയ്യുന്നു...");
    ADD("login_must_change","Password Change Required","രഹസ്യവാക്ക് മാറ്റേണ്ടതുണ്ട്");
    ADD("nav_dashboard","Dashboard","ഡാഷ്ബോർഡ്");
    ADD("nav_families","Families","കുടുംബങ്ങൾ");
    ADD("nav_members","Members","അംഗങ്ങൾ");
    ADD("nav_subscriptions","Subscriptions","സബ്സ്ക്രിപ്ഷൻ");
    ADD("nav_donations","Donations","സംഭാവനകൾ");
    ADD("nav_accounting","Accounting","അക്കൗണ്ടിംഗ്");
    ADD("nav_marriage","Marriage Register","വിവാഹ രജിസ്റ്റർ");
    ADD("nav_death","Death Register","മരണ രജിസ്റ്റർ");
    ADD("nav_welfare","Welfare","ക്ഷേമം");
    ADD("nav_certificates","Certificates","സർട്ടിഫിക്കറ്റുകൾ");
    ADD("nav_reports","Reports","റിപ്പോർട്ടുകൾ");
    ADD("nav_settings","Settings","ക്രമീകരണങ്ങൾ");
    ADD("nav_users","Users","ഉപയോക്താക്കൾ");
    ADD("nav_audit","Audit Log","ഓഡിറ്റ് ലോഗ്");
    ADD("nav_backup","Backup & Restore","ബാക്കപ്പ് & റെസ്റ്റോർ");
    ADD("action_add","Add","ചേർക്കുക");
    ADD("action_edit","Edit","തിരുത്തുക");
    ADD("action_delete","Delete","ഇല്ലാതാക്കുക");
    ADD("action_save","Save","സേവ്");
    ADD("action_cancel","Cancel","റദ്ദാക്കുക");
    ADD("action_search","Search","തിരയുക");
    ADD("action_print","Print","പ്രിന്റ്");
    ADD("action_export","Export","കയറ്റുമതി");
    ADD("action_refresh","Refresh","പുതുക്കുക");
    ADD("action_archive","Archive","ആർക്കൈവ്");
    ADD("action_approve","Approve","അംഗീകരിക്കുക");
    ADD("action_reject","Reject","നിരസിക്കുക");
    ADD("action_disburse","Disburse","വിതരണം ചെയ്യുക");
    ADD("action_generate","Generate","ജനറേറ്റ്");
    ADD("action_unlock","Unlock","അൺലോക്ക്");
    ADD("action_reset_password","Reset Password","രഹസ്യവാക്ക് പുനഃസജ്ജമാക്കുക");
    ADD("action_change_password","Change Password...","രഹസ്യവാക്ക് മാറ്റുക...");
    ADD("action_logout","Logout","ലോഗ്ഔട്ട്");
    ADD("action_toggle_theme","Toggle Theme","തീം മാറ്റുക");
    ADD("action_toggle_language","Language","ഭാഷ");
    ADD("action_next","Next","അടുത്തത്");
    ADD("action_previous","Previous","മുമ്പത്തെ");
    ADD("action_page","Page","പേജ്");
    ADD("dash_title","Dashboard","ഡാഷ്ബോർഡ്");
    ADD("dash_greeting","Assalamu Alaikum,","അസ്സലാമു അലൈക്കും,");
    ADD("dash_subtitle","Here's what's happening in your mahallu today.","നിങ്ങളുടെ മഹല്ലിലെ ഇന്നത്തെ അവലോകനം.");
    ADD("dash_recent_activity_sub","Latest user actions across all modules","എല്ലാ മൊഡ്യൂളുകളിലെയും പുതിയ ഉപയോക്തൃ പ്രവർത്തനങ്ങൾ");
    ADD("dash_total_families","Total Families","മൊത്തം കുടുംബങ്ങൾ");
    ADD("dash_total_members","Total Members","മൊത്തം അംഗങ്ങൾ");
    ADD("dash_active_members","Active Members","സജീവ അംഗങ്ങൾ");
    ADD("dash_monthly_collection","Monthly Collection","പ്രതിമാസ പിരിവ്");
    ADD("dash_pending_dues","Pending Dues","ബാക്കി തുക");
    ADD("dash_donations_month","Donations (Month)","സംഭാവനകൾ (മാസം)");
    ADD("dash_welfare_disbursed","Welfare Disbursed","ക്ഷേമ വിതരണം");
    ADD("dash_marriages_year","Marriages (Year)","വിവാഹങ്ങൾ (വർഷം)");
    ADD("dash_deaths_year","Deaths (Year)","മരണങ്ങൾ (വർഷം)");
    ADD("dash_balance_month","Balance (Month)","ബാലൻസ് (മാസം)");
    ADD("dash_quick_add_family","Add Family","കുടുംബം ചേർക്കുക");
    ADD("dash_quick_add_member","Add Member","അംഗം ചേർക്കുക");
    ADD("dash_quick_record_payment","Record Payment","പേയ്മെന്റ് രേഖപ്പെടുത്തുക");
    ADD("dash_quick_add_donation","Add Donation","സംഭാവന ചേർക്കുക");
    ADD("dash_quick_generate_report","Generate Report","റിപ്പോർട്ട് ജനറേറ്റ്");
    ADD("dash_recent_activity","Recent Activity","സമീപകാല പ്രവർത്തനങ്ങൾ");
    ADD("dash_chart_collections","Monthly Collections","പ്രതിമാസ പിരിവ്");
    ADD("dash_chart_donations","Donations by Category","വിഭാഗം അനുസരിച്ച് സംഭാവനകൾ");
    ADD("dash_chart_income_expense","Income vs Expense","വരുമാനം vs ചെലവ്");
    ADD("dash_chart_membership_growth","Membership Growth","അംഗത്വ വളർച്ച");
    ADD("family_title","Family Management","കുടുംബ ഭരണം");
    ADD("family_number","Family No","കുടുംബ നമ്പർ");
    ADD("family_house_name","House Name","വീടിന്റെ പേര്");
    ADD("family_house_number","House Number","വീട്ട് നമ്പർ");
    ADD("family_ward","Ward","വാർഡ്");
    ADD("family_area","Area","പ്രദേശം");
    ADD("family_address","Address","വിലാസം");
    ADD("family_pincode","Pincode","പിൻകോഡ്");
    ADD("family_phone","Phone","ഫോൺ");
    ADD("family_alt_phone","Alt. Phone","ബദൽ ഫോൺ");
    ADD("family_status","Status","നില");
    ADD("family_members_count","Members","അംഗങ്ങൾ");
    ADD("family_notes","Notes","കുറിപ്പുകൾ");
    ADD("family_add","Add Family","കുടുംബം ചേർക്കുക");
    ADD("family_edit","Edit Family","കുടുംബം തിരുത്തുക");
    ADD("family_archived","Archived","ആർക്കൈവ്");
    ADD("family_archive_confirm","Archive this family? It can be restored later.","ഈ കുടുംബം ആർക്കൈവ് ചെയ്യണമോ? പിന്നീട് പുനഃസ്ഥാപിക്കാം.");
    ADD("family_delete_confirm","Permanently delete this family?","ഈ കുടുംബം എന്നെന്നേക്കുമായി ഇല്ലാതാക്കണമോ?");
    ADD("family_search_placeholder","Search by family no, house name, phone, area...","കുടുംബ നമ്പർ, വീടിന്റെ പേര്, ഫോൺ എന്നിവ ഉപയോഗിച്ച് തിരയുക...");
    ADD("member_title","Member Management","അംഗ ഭരണം");
    ADD("member_code","Code","കോഡ്");
    ADD("member_name","Name","പേര്");
    ADD("member_arabic_name","Arabic Name","അറബി പേര്");
    ADD("member_gender","Gender","ലിംഗം");
    ADD("member_dob","Date of Birth","ജനന തീയതി");
    ADD("member_age","Age","പ്രായം");
    ADD("member_blood_group","Blood Group","രക്തഗ്രൂപ്പ്");
    ADD("member_occupation","Occupation","തൊഴിൽ");
    ADD("member_education","Education","വിദ്യാഭ്യാസം");
    ADD("member_marital_status","Marital Status","വൈവാഹിക നില");
    ADD("member_mobile","Mobile","മൊബൈൽ");
    ADD("member_email","Email","ഇമെയിൽ");
    ADD("member_nationality","Nationality","ദേശീയത");
    ADD("member_emergency_contact","Emergency Contact","അടിയന്തര ബന്ധം");
    ADD("member_relationship","Relationship","ബന്ധം");
    ADD("member_photo","Photo","ഫോട്ടോ");
    ADD("member_upload_photo","Upload Photo","ഫോട്ടോ അപ്ലോഡ്");
    ADD("member_add","Add Member","അംഗം ചേർക്കുക");
    ADD("member_search_placeholder","Search members by name, code, mobile, email...","പേര്, കോഡ്, മൊബൈൽ എന്നിവ ഉപയോഗിച്ച് തിരയുക...");
    ADD("member_male","Male","പുരുഷൻ");
    ADD("member_female","Female","സ്ത്രീ");
    ADD("member_other","Other","മറ്റുള്ളവ");
    ADD("member_active","Active","സജീവം");
    ADD("member_inactive","Inactive","നിർജീവം");
    ADD("member_deceased","Deceased","മരിച്ചു");
    ADD("member_family","Family","കുടുംബം");
    ADD("sub_title","Subscription Management","സബ്സ്ക്രിപ്ഷൻ ഭരണം");
    ADD("sub_receipt","Receipt","രസീത്");
    ADD("sub_plan","Plan","പ്ലാൻ");
    ADD("sub_amount","Amount","തുക");
    ADD("sub_amount_paid","Paid","അടച്ചു");
    ADD("sub_payment_date","Payment Date","പേയ്മെന്റ് തീയതി");
    ADD("sub_method","Method","രീതി");
    ADD("sub_status","Status","നില");
    ADD("sub_period_start","Period Start","കാലയളവ് ആരംഭം");
    ADD("sub_period_end","Period End","കാലയളവ് അവസാനം");
    ADD("sub_record_payment","Record Payment","പേയ്മെന്റ് രേഖപ്പെടുത്തുക");
    ADD("sub_mark_overdue","Mark Overdue","കാലഹരണപ്പെട്ടതായി അടയാളപ്പെടുത്തുക");
    ADD("sub_defaulters_tab","Defaulters","സ്ഥിരസ്ഥിതി ലംഘിക്കുന്നവർ");
    ADD("sub_paid","Paid","അടച്ചു");
    ADD("sub_pending","Pending","ബാക്കി");
    ADD("sub_overdue","Overdue","കാലഹരണപ്പെട്ടു");
    ADD("sub_partial","Partial","ഭാഗികം");
    ADD("sub_method_cash","Cash","പണം");
    ADD("sub_method_cheque","Cheque","ചെക്ക്");
    ADD("sub_method_upi","UPI","യുപിഐ");
    ADD("sub_method_bank","Bank Transfer","ബാങ്ക് ട്രാൻസ്ഫർ");
    ADD("sub_method_card","Card","കാർഡ്");
    ADD("don_title","Donation Management","സംഭാവന ഭരണം");
    ADD("don_donor_name","Donor Name","സംഭാവകന്റെ പേര്");
    ADD("don_donor_phone","Donor Phone","സംഭാവകന്റെ ഫോൺ");
    ADD("don_category","Category","വിഭാഗം");
    ADD("don_date","Date","തീയതി");
    ADD("don_purpose","Purpose","ഉദ്ദേശ്യം");
    ADD("don_add","Add Donation","സംഭാവന ചേർക്കുക");
    ADD("acc_title","Accounting","അക്കൗണ്ടിംഗ്");
    ADD("acc_type","Type","തരം");
    ADD("acc_account","Account","അക്കൗണ്ട്");
    ADD("acc_description","Description","വിവരണം");
    ADD("acc_income","Income","വരുമാനം");
    ADD("acc_expense","Expense","ചെലവ്");
    ADD("acc_balance","Balance","ബാലൻസ്");
    ADD("acc_reference","Reference","റഫറൻസ്");
    ADD("acc_add_income","Add Income","വരുമാനം ചേർക്കുക");
    ADD("acc_add_expense","Add Expense","ചെലവ് ചേർക്കുക");
    ADD("mrg_title","Marriage Register","വിവാഹ രജിസ്റ്റർ");
    ADD("mrg_number","Marriage No","വിവാഹ നമ്പർ");
    ADD("mrg_bride","Bride","വധു");
    ADD("mrg_groom","Groom","വരൻ");
    ADD("mrg_bride_father","Bride Father","വധുവിന്റെ പിതാവ്");
    ADD("mrg_groom_father","Groom Father","വരന്റെ പിതാവ്");
    ADD("mrg_nikah_date","Nikah Date","നികാഹ് തീയതി");
    ADD("mrg_registration_date","Registration Date","രജിസ്ട്രേഷൻ തീയതി");
    ADD("mrg_witness","Witness","സാക്ഷി");
    ADD("mrg_mahar","Mahar","മഹർ");
    ADD("mrg_place","Place","സ്ഥലം");
    ADD("mrg_register","Register Marriage","വിവാഹം രജിസ്റ്റർ ചെയ്യുക");
    ADD("dth_title","Death Register","മരണ രജിസ്റ്റർ");
    ADD("dth_number","Death No","മരണ നമ്പർ");
    ADD("dth_deceased","Deceased","മൃതൻ");
    ADD("dth_father","Father Name","പിതാവിന്റെ പേര്");
    ADD("dth_date_of_death","Date of Death","മരണ തീയതി");
    ADD("dth_burial_date","Burial Date","ഖബർ സ്ഥാപന തീയതി");
    ADD("dth_cause","Cause of Death","മരണ കാരണം");
    ADD("dth_burial_place","Burial Place","ഖബർസ്ഥാനം");
    ADD("dth_register","Register Death","മരണം രജിസ്റ്റർ ചെയ്യുക");
    ADD("wel_title","Welfare Management","ക്ഷേമ ഭരണം");
    ADD("wel_request_no","Request No","അപേക്ഷ നമ്പർ");
    ADD("wel_applicant","Applicant","അപേക്ഷകൻ");
    ADD("wel_amount_requested","Requested","ആവശ്യപ്പെട്ടത്");
    ADD("wel_amount_approved","Approved","അംഗീകൃതം");
    ADD("wel_reason","Reason","കാരണം");
    ADD("wel_new_request","New Request","പുതിയ അപേക്ഷ");
    ADD("cert_title","Certificates","സർട്ടിഫിക്കറ്റുകൾ");
    ADD("cert_membership","Membership","അംഗത്വം");
    ADD("cert_residence","Residence","വസതി");
    ADD("cert_marriage","Marriage","വിവാഹം");
    ADD("cert_death","Death","മരണം");
    ADD("cert_generate_pdf","Generate PDF","PDF ജനറേറ്റ്");
    ADD("rpt_title","Reports","റിപ്പോർട്ടുകൾ");
    ADD("rpt_generate","Generate","ജനറേറ്റ്");
    ADD("set_title","Settings","ക്രമീകരണങ്ങൾ");
    ADD("set_theme","Theme","തീം");
    ADD("set_theme_light","Light","ലൈറ്റ്");
    ADD("set_theme_dark","Dark","ഡാർക്ക്");
    ADD("set_language","Language","ഭാഷ");
    ADD("set_save","Save Settings","ക്രമീകരണങ്ങൾ സേവ്");
    ADD("audit_title","Audit Log","ഓഡിറ്റ് ലോഗ്");
    ADD("audit_time","Time","സമയം");
    ADD("audit_user","User","ഉപയോക്താവ്");
    ADD("audit_action","Action","പ്രവർത്തി");
    ADD("audit_module","Module","മോഡ്യൂൾ");
    ADD("audit_description","Description","വിവരണം");
    ADD("bak_title","Backup & Restore","ബാക്കപ്പ് & റെസ്റ്റോർ");
    ADD("bak_create_now","Create Backup Now","ഇപ്പോൾ ബാക്കപ്പ് ഉണ്ടാക്കുക");
    ADD("bak_restore","Restore","റെസ്റ്റോർ");
    ADD("bak_verify","Verify","പരിശോധിക്കുക");
    ADD("bak_prune","Prune Old","പഴയവ നീക്കുക");
    ADD("usr_title","User Management","ഉപയോക്തൃ ഭരണം");
    ADD("usr_username","Username","ഉപയോക്തൃനാമം");
    ADD("usr_full_name","Full Name","പൂർണ്ണ പേര്");
    ADD("usr_role","Role","റോൾ");
    ADD("usr_add","Add User","ഉപയോക്താവ് ചേർക്കുക");
    ADD("ui_select_family","Select Family","കുടുംബം തിരഞ്ഞെടുക്കുക");
    ADD("ui_select_family_first","Please select a family first","ദയവായി ആദ്യം ഒരു കുടുംബം തിരഞ്ഞെടുക്കുക");
    ADD("ui_no_members_in_family","No members in this family","ഈ കുടുംബത്തിൽ അംഗങ്ങളില്ല");
    ADD("ui_records","records","രേഖകൾ");
    ADD("ui_success","Success","വിജയം");
    ADD("ui_no_data","No data found","ഡാറ്റ കണ്ടെത്തിയില്ല");
    ADD("ui_error","Error","പിശക്");
    ADD("val_save_failed","Save Failed","സേവ് പരാജയപ്പെട്ടു");
    ADD("val_password_policy","Password must be at least 8 characters with upper, lower, digit, and special character.","രഹസ്യവാക്ക് കുറഞ്ഞത് 8 പ്രതീകങ്ങളും വലുപ്പചിഹ്നം, ചെറിയചിഹ്നം, അക്കം, പ്രത്യേക പ്രതീകം എന്നിവ ഉൾപ്പെടണം.");
    ADD("form_select","— Select —","— തിരഞ്ഞെടുക്കുക —");
    ADD("form_none","— None —","— ശൂന്യം —");
    ADD("acc_type_income","Income","വരുമാനം");
    ADD("acc_type_expense","Expense","ചെലവ്");
    ADD("ui_all_categories","All Categories","എല്ലാ വിഭാഗങ്ങളും");
    ADD("ui_type","Type","തരം");
    ADD("ui_from","From","നിന്ന്");
    ADD("ui_to","To","വരെ");
    ADD("ui_category","Category","വിഭാഗം");
    ADD("member_single","Single","അവിവാഹിതൻ");
    ADD("member_divorced","Divorced","വിവാഹമോചിതൻ");
    ADD("member_widowed","Widowed","വിധവ");
    ADD("member_sibling","Sibling","സഹോദരൻ");

    #undef ADD
    Logger::info(QString("I18N initialized with %1 translations").arg(translations_.size()));
}

QString I18N::tr(const QString& key) {
    auto& inst = instance();
    auto it = inst.translations_.constFind(key);
    if (it == inst.translations_.constEnd()) return key;
    auto langIt = it->constFind(inst.currentLang_);
    if (langIt == it->constEnd()) {
        langIt = it->constFind("en");
        if (langIt == it->constEnd()) return key;
    }
    return langIt.value();
}

void I18N::setLanguage(const QString& langCode) {
    if (langCode != "en" && langCode != "ml") return;
    if (currentLang_ == langCode) return;
    currentLang_ = langCode;
    Config::instance().setLanguage(langCode);
    Logger::info("Language changed to: " + langCode);
    if (callback_) callback_(langCode);
}

QString I18N::languageDisplayName(const QString& code) const {
    if (code == "en") return "English";
    if (code == "ml") return QString::fromUtf8("മലയാളം");
    return code;
}

void I18N::loadFromSettings() {
    QString lang = Config::instance().language();
    if (lang.isEmpty()) lang = "en";
    currentLang_ = lang;
    Logger::info("Loaded language from settings: " + lang);
}

} // namespace mms
