# New Pixelita App

Announce each section to the user as you start it.

## 🚀 App Creation

1. Echo, with stars and colors: `Thank you for bringing a new app to the world of Pixelita !`
2. Ask the user for the name of the new app.
3. Run: `flutter create --org fr.toto --platforms ios,android,web <app_name_in_snake_case>`
4. Clean the generated app and make the home screen display: `Another wonderful app by Pixelita`
5. Match the structure of the `touchstone/blueprint` project as closely as possible, omitting any files not needed for this home screen.

## 🗿 Touchstone

1. Add the `touchstone` repo as a git submodule at the root of the new app.
2. Add a `CLAUDE.md` containing:
  > @touchstone/ai/CLAUDE.md : Your default instructions.
  > Every time you write code, always make sure the app uses the same practices, architecture, folder structure, naming conventions, dependencies and theming as the reference @touchstone/blueprint.

