# New Pixelita App

When this file is referenced without any instructions, it means that you should run all the steps.

Announce each step to the user when you start it.

## 🚀 App Creation

1. Echo, with stars and colors: `Thank you for bringing a new app to the world of Pixelita !`
2. Ask the user for the name of the new app. This will be the displayed name.
3. Ask confirmation for the bundle ID that it will generate : `dev.pixelita.<app_name_in_flat_case>`
4. If user specifies a space, a dash or any character that is not a letter, say : "The bundle ID is invalid (we ask flatCase to make bundle ID consistent between Android and iOS)"
5. Ask user for the languages (English is mandatory and will be default language)
6. In folder `stones/`, run: `flutter create --org <org> --platforms ios,android,web <app_name_in_flat_case>`

  `<org>` is `dev.pixelita` or something else if user specified so in the last step
7. Clean the generated app, remove all comments
8. Make the home screen display: `Another wonderful app by Pixelita` 
  This is the only reference to Pixelita, Pixelita should not be written in Metadata.

## 🗿 Blueprint

1. Match the structure of the `touchstone/blueprint` project as closely as possible, omitting any files not needed for this home screen, and ommitting the `.version` file.
2. Do not set up preferences (e.g. `app_preferences.dart` and its wiring) in the crafted app, unless the user explicitly asked for them.
3. Copy file [CLAUDE.md](http://CLAUDE.md) from `touchstone/blueprint` and paste it in the root of the created project.
4. Copy the `.claude/` folder from `touchstone/blueprint` to the root of the created project, adjusting the symlinks so they reference the `ai/.claude` folder of touchstone, relative to the new project folder (e.g. `settings.json -> ../../../ai/.claude/settings.json` and `skills -> ../../../ai/.claude/skills` for a project in `stones/<app_name>`).

## ☁️ Github

1. Ask user if he wants to create a repository on Github
2. If yes, ask if it should be public/private
3. Create the repository for the project, using CLI `gh`

