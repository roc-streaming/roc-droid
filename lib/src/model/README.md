# Model architecture description

**Table of contents:**

- [Model architecture description](#model-architecture-description)
  - [Model tree](#model-tree)

## Model tree

![](/docs/images/model.png)

The roc-droid `Model` module is responsible for managing the data model of the application's graphical interface. Data changes in the model are initiated by the `Agent` module and then utilized by the `UI` module.

Description of the model tree:

* The roc-droid client application's model is based on the `ModelRoot` class, highlighted in violet.
  
  * Class implementation: [ModelRoot](/lib/src/model/model_root.dart)

* The `ModelRoot` class itself is derived from two base classes: `Receiver` and `Sender`, both highlighted in red.

  * Receiver implementation: [Receiver](/lib/src/model/receiver.dart)

  * Sender implementation: [Sender](/lib/src/model/sender.dart)
