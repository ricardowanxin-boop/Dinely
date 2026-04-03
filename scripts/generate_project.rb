#!/usr/bin/env ruby

require "fileutils"

workspace_root = File.expand_path("..", __dir__)

begin
  require "xcodeproj"
rescue LoadError
  warn "Missing gem: xcodeproj"
  warn "Install it with: gem install xcodeproj"
  exit 1
end

PROJECT_NAME = "DineRank"
PROJECT_PATH = File.join(workspace_root, "#{PROJECT_NAME}.xcodeproj")
APP_FOLDER = "DineRank"
WIDGET_EXTENSION_NAME = "DineRankWidgetsExtension"
UI_TEST_TARGET_NAME = "#{PROJECT_NAME}UITests"

SOURCE_FILES = %w[
  DineRank/App/DineRankApp.swift
  DineRank/App/RootView.swift
  DineRank/Models/AppModels.swift
  DineRank/Models/LiveActivityModels.swift
  DineRank/Services/JSONFileStore.swift
  DineRank/Services/APIClient.swift
  DineRank/Services/DemoContentRepository.swift
  DineRank/Services/StoreKitService.swift
  DineRank/Services/LiveActivityManager.swift
  DineRank/Services/NotificationManager.swift
  DineRank/Services/BackgroundRefreshService.swift
  DineRank/Services/LocalStores.swift
  DineRank/Support/AppConfig.swift
  DineRank/Support/L10n.swift
  DineRank/Support/AppTheme.swift
  DineRank/Support/AppRuntime.swift
  DineRank/Support/DisplayFormatters.swift
  DineRank/Support/SharedDefaults.swift
  DineRank/Support/SampleData.swift
  DineRank/ViewModels/HomeViewModel.swift
  DineRank/Views/HomeScreen.swift
  DineRank/Views/ComponentsScreen.swift
  DineRank/Views/CapabilitiesScreen.swift
  DineRank/Views/SettingsScreen.swift
  DineRank/Views/Components/TemplateComponents.swift
].freeze

RESOURCE_FILES = %w[
  DineRank/Resources/Assets.xcassets
  DineRank/Resources/en.lproj/Localizable.strings
  DineRank/Resources/en.lproj/InfoPlist.strings
].freeze

GROUP_ONLY_FILES = %w[
  DineRank/Resources/Info.plist
  DineRank/Resources/DineRank.entitlements
].freeze

WIDGET_SOURCE_FILES = %w[
  DineRank/Models/AppModels.swift
  DineRank/Models/LiveActivityModels.swift
  DineRank/Support/AppConfig.swift
  DineRank/Support/DisplayFormatters.swift
  DineRank/Support/L10n.swift
  DineRank/Support/SharedDefaults.swift
  DineRank/Support/SampleData.swift
  DineRankWidgetsExtension/DineRankWidgetsBundle.swift
].freeze

WIDGET_RESOURCE_FILES = %w[
  DineRankWidgetsExtension/en.lproj/Localizable.strings
  DineRankWidgetsExtension/en.lproj/InfoPlist.strings
].freeze

WIDGET_GROUP_ONLY_FILES = %w[
  DineRankWidgetsExtension/Info.plist
  DineRankWidgetsExtension/DineRankWidgetsExtension.entitlements
].freeze

UI_TEST_SOURCE_FILES = %w[
  DineRankUITests/DineRankUITests.swift
].freeze

def ensure_group(root_group, relative_dir)
  return root_group if relative_dir == "." || relative_dir.empty?

  relative_dir.split("/").reduce(root_group) do |parent, component|
    parent.groups.find { |group| group.display_name == component } || parent.new_group(component, component)
  end
end

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes["LastSwiftUpdateCheck"] = "2600"
project.root_object.attributes["LastUpgradeCheck"] = "2600"

app_target = project.new_target(:application, PROJECT_NAME, :ios, "17.0")
widget_target = project.new_target(:app_extension, WIDGET_EXTENSION_NAME, :ios, "17.0")
ui_test_target = project.new_target(:ui_test_bundle, UI_TEST_TARGET_NAME, :ios, "17.0")

project.build_configurations.each do |config|
  config.build_settings["SWIFT_VERSION"] = "5.0"
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
end

app_target.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.ricardo.dinerank"
  settings["INFOPLIST_FILE"] = "DineRank/Resources/Info.plist"
  settings["GENERATE_INFOPLIST_FILE"] = "NO"
  settings["SWIFT_VERSION"] = "5.0"
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  settings["TARGETED_DEVICE_FAMILY"] = "1"
  settings["MARKETING_VERSION"] = "1.0"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["CODE_SIGN_STYLE"] = "Automatic"
  settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
  settings["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"] = "AccentColor"
  settings["LD_RUNPATH_SEARCH_PATHS"] = ["$(inherited)", "@executable_path/Frameworks"]
  settings["CODE_SIGN_ENTITLEMENTS"] = "DineRank/Resources/DineRank.entitlements"
end

widget_target.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.ricardo.dinerank.widgets"
  settings["INFOPLIST_FILE"] = "DineRankWidgetsExtension/Info.plist"
  settings["GENERATE_INFOPLIST_FILE"] = "NO"
  settings["SWIFT_VERSION"] = "5.0"
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  settings["TARGETED_DEVICE_FAMILY"] = "1"
  settings["MARKETING_VERSION"] = "1.0"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["CODE_SIGN_STYLE"] = "Automatic"
  settings["APPLICATION_EXTENSION_API_ONLY"] = "YES"
  settings["SKIP_INSTALL"] = "YES"
  settings["CODE_SIGN_ENTITLEMENTS"] = "DineRankWidgetsExtension/DineRankWidgetsExtension.entitlements"
end

ui_test_target.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.ricardo.dinerank.uitests"
  settings["GENERATE_INFOPLIST_FILE"] = "YES"
  settings["SWIFT_VERSION"] = "5.0"
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  settings["TARGETED_DEVICE_FAMILY"] = "1"
  settings["MARKETING_VERSION"] = "1.0"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["CODE_SIGN_STYLE"] = "Automatic"
  settings["TEST_TARGET_NAME"] = PROJECT_NAME
end

all_group_files = SOURCE_FILES + RESOURCE_FILES + GROUP_ONLY_FILES + WIDGET_SOURCE_FILES + WIDGET_RESOURCE_FILES + WIDGET_GROUP_ONLY_FILES + UI_TEST_SOURCE_FILES
all_group_files.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  next if group.files.any? { |file| file.path == File.basename(relative_path) }

  group.new_file(File.basename(relative_path))
end

SOURCE_FILES.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  file_ref = group.files.find { |file| file.path == File.basename(relative_path) }
  app_target.source_build_phase.add_file_reference(file_ref, true)
end

RESOURCE_FILES.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  file_ref = group.files.find { |file| file.path == File.basename(relative_path) }
  app_target.resources_build_phase.add_file_reference(file_ref, true)
end

WIDGET_SOURCE_FILES.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  file_ref = group.files.find { |file| file.path == File.basename(relative_path) }
  widget_target.source_build_phase.add_file_reference(file_ref, true)
end

WIDGET_RESOURCE_FILES.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  file_ref = group.files.find { |file| file.path == File.basename(relative_path) }
  widget_target.resources_build_phase.add_file_reference(file_ref, true)
end

UI_TEST_SOURCE_FILES.each do |relative_path|
  group = ensure_group(project.main_group, File.dirname(relative_path))
  file_ref = group.files.find { |file| file.path == File.basename(relative_path) }
  ui_test_target.source_build_phase.add_file_reference(file_ref, true)
end

app_target.add_dependency(widget_target)
ui_test_target.add_dependency(app_target)

embed_phase = app_target.copy_files_build_phases.find { |phase| phase.name == "Embed App Extensions" } || app_target.new_copy_files_build_phase("Embed App Extensions")
embed_phase.dst_subfolder_spec = "13"
embed_build_file = embed_phase.add_file_reference(widget_target.product_reference, true)
embed_build_file.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }

project.root_object.attributes["TargetAttributes"] ||= {}
project.root_object.attributes["TargetAttributes"][ui_test_target.uuid] = { "TestTargetID" => app_target.uuid }
project.root_object.development_region = "zh-Hans"
project.root_object.known_regions = %w[zh-Hans en]

project.save

puts "Generated #{PROJECT_PATH}"
