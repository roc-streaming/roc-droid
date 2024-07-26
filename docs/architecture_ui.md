# User interface architecture description

**Table of contents:**

- [User interface architecture description](#user-interface-architecture-description)
  - [Widget types](#widget-types)
  - [Widget tree](#widget-tree)

## Widget types

![](/docs/images/widget_types.png)

Widgets can be categorized into the following types:

* **Content Layer**

    Widgets at this level define the application's structure (layout) and the binding of the content (models) to the representation (components from the representation layer). These widgets actively interact with the model layer using the Observer pattern.

    Sublevels:

    * `Screen`: This widget corresponds to the entire screen.
    
    * `Page`: This widget represents a page within the screen. Switching between pages is done via the lower tab bar.
    
    * `Fragment`: This widget represents a smaller fragment of the UI, such as a separate block or item in a list.

* **Representation Layer**

    Widgets at this level, known as components, are the building blocks of the UI. A component defines its appearance and user interaction but is not tied to specific content (model).

    Sublevels:

    * `roc Component`: Custom components that can implement application-specific styles or interface elements.
    
    * `Flutter Component`: Standard components from the Flutter SDK.
    
    Fragment vs. Component
    
    It's important to understand the difference between a fragment and a component:

    * `Fragment`: Responsible for communication with specific data (models or defined data). However, it is not responsible for a specific representation; this task is delegated to the components.
    
    * `Component`: Not tied to specific data—it receives data from above and does not interact with models. It is responsible for implementing a specific representation, such as styles and responses to clicks.
    
    > **Note:** In our code, custom component classes are prefixed with `roc` to distinguish them from standard components. Other types of widgets do not have a special prefix.

    > **Note:** In some frameworks, an entity similar to a fragment is called a `widget`. We use the term `fragment` for clarity (like in Android SDK).

## Widget tree

![](/docs/images/widget_tree.png)

The UI diagram of the Rock Droid application client illustrates a tree of widgets that form the visual presentation for the user.

Designations:

* **Purple:** Root class of the UI application (`Content Layer`)

  * roc-droid classes:

    * [AppRoot](/lib/src/ui/app_root.dart)

* **Red:** Screen-level widgets (`Content Layer`)

  * roc-droid classes:

    * [MainScreen](/lib/src/ui/main_screen.dart)

* **Orange:** Page-level widgets (`Content Layer`)

  * roc-droid classes:

    * [ReceiverPage](/lib/src/ui/receiver_page.dart)
  
    * [SenderPage](/lib/src/ui/sender_page.dart)

* **Yellow:** Fragment-level widgets (`Content Layer`)

  * Classes:

    * [AboutPage](/lib/src/ui/fragments/about_page.dart)

* **Gray:** Native Flutter `Widget` class (`Representation Layer`)

* **Blue:** Custom Roc `Widget` class (`Representation Layer`)

  * These classes are also divided into the following types:

    * Data widgets:
  
      * Location: `/lib/src/ui/components/data_widgets/`
  
      * Representing classes that provide certain data to the user.

      * Only widget extensions are allowed for this type.
  
    * Input widgets:
  
      * Location: `/lib/src/ui/components/input_widgets/`

      * These are classes that provide the user with the ability to enter certain data.

      * Stetless, Statefull and extension widgets are allowed for this type.
  
    * Scaffold widgets:
  
      * Location: `/lib/src/ui/components/scaffold_widgets/`

      * A set of special widgets that control the appearance of scaffold elements.

      * Only widget extensions are allowed for this type.
  
    * Util widgets:
  
      * Location: `/lib/src/ui/components/util_widgets/`

      * Help and debugging utility widgets.
  
      * Stetless, Statefull and extension widgets are allowed for this type.
  
    * View widgets:

      * Location: `/lib/src/ui/components/view_widgets/`

      * Widgets that control specific view representations.
  
      * Only stetless widgets are allowed for this type.
