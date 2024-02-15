export function reduceErrors(editMode, templateArray) {
  const createUI =
  [
    { Id: "approvedTemplates", isVisible: true, isDisable : true},
    { Id: "category",  isVisible: true, isDisable : true},
    { Id: "language",  isVisible: true, isDisable : true},
    { Id: "AttributeCombobox",  isVisible: true, isDisable : false},
    { Id: "AttributeButton",  isVisible: true, isDisable : false},
    { Id: "messageBody", isVisible: true, isDisable : false},
    { Id: "HeaderRadioGroup", isVisible: true, isDisable : false},
    { Id: "HeaderText", isVisible: true, isDisable : false},
    { Id: "HeaderMediaRadio", isVisible: true, isDisable : false},
    { Id: "HeaderMediaURL", isVisible: true, isDisable : false},
    { Id: "Footer", isVisible: true, isDisable : false},
    { Id: "InteractiveTypeRadio", isVisible: true, isDisable : false},
    { Id: "templateType", isVisible: true, isDisable : false},
    { Id: "createNewOrExisting", isVisible: true, isDisable : true}
  ];

  const editUI =
  [
    { Id: "approvedTemplates", isVisible: true, isDisable : true},
    { Id: "category",  isVisible: true, isDisable : true},
    { Id: "language",  isVisible: true, isDisable : true},
    { Id: "AttributeCombobox",  isVisible: true, isDisable : false},
    { Id: "AttributeButton",  isVisible: true, isDisable : false},
    { Id: "messageBody", isVisible: true, isDisable : false},
    { Id: "HeaderRadioGroup", isVisible: true, isDisable : false},
    { Id: "HeaderText", isVisible: true, isDisable : false},
    { Id: "HeaderMediaRadio", isVisible: true, isDisable : false},
    { Id: "HeaderMediaURL", isVisible: true, isDisable : false},
    { Id: "Footer", isVisible: true, isDisable : false},
    { Id: "InteractiveTypeRadio", isVisible: true, isDisable : false},
    { Id: "templateType", isVisible: true, isDisable : true},
    { Id: "createNewOrExisting", isVisible: true, isDisable : true}
 ];

  const createBI =
  [
    { Id: "approvedTemplates", isVisible: true, isDisable : false},
    { Id: "category",  isVisible: true, isDisable : true},
    { Id: "language",  isVisible: true, isDisable : true},
    { Id: "AttributeCombobox",  isVisible: true, isDisable : true},
    { Id: "AttributeButton",  isVisible: true, isDisable : true},
    { Id: "messageBody", isVisible: true, isDisable : true},
    { Id: "HeaderRadioGroup", isVisible: true, isDisable : true},
    { Id: "HeaderText", isVisible: true, isDisable : true},
    { Id: "HeaderMediaRadio", isVisible: true, isDisable : true},
    { Id: "HeaderMediaURL", isVisible: true, isDisable : true},
    { Id: "Footer", isVisible: true, isDisable : true},
    { Id: "InteractiveTypeRadio", isVisible: true, isDisable : true},
    { Id: "templateType", isVisible: true, isDisable : false},
    { Id: "createNewOrExisting", isVisible: true, isDisable : false}
 ];
  const createBINew =
  [
    { Id: "approvedTemplates", isVisible: true, isDisable : false},
    { Id: "category",  isVisible: true, isDisable : false},
    { Id: "language",  isVisible: true, isDisable : false},
    { Id: "AttributeCombobox",  isVisible: true, isDisable : false},
    { Id: "AttributeButton",  isVisible: true, isDisable : false},
    { Id: "messageBody", isVisible: true, isDisable : false},
    { Id: "HeaderRadioGroup", isVisible: true, isDisable : false},
    { Id: "HeaderText", isVisible: true, isDisable : false},
    { Id: "HeaderMediaRadio", isVisible: true, isDisable : false},
    { Id: "HeaderMediaURL", isVisible: true, isDisable : false},
    { Id: "Footer", isVisible: true, isDisable : false},
    { Id: "InteractiveTypeRadio", isVisible: true, isDisable : false},
    { Id: "templateType", isVisible: true, isDisable : false},
    { Id: "createNewOrExisting", isVisible: true, isDisable : false}
 ];
  const editBI =
  [
    { Id: "approvedTemplates", isVisible: true, isDisable : true},
    { Id: "category",  isVisible: true, isDisable : false},
    { Id: "language",  isVisible: true, isDisable : false},
    { Id: "AttributeCombobox",  isVisible: true, isDisable : false},
    { Id: "AttributeButton",  isVisible: true, isDisable : false},
    { Id: "messageBody", isVisible: true, isDisable : false},
    { Id: "HeaderRadioGroup", isVisible: true, isDisable : false},
    { Id: "HeaderText", isVisible: true, isDisable : false},
    { Id: "HeaderMediaRadio", isVisible: true, isDisable : false},
    { Id: "HeaderMediaURL", isVisible: true, isDisable : false},
    { Id: "Footer", isVisible: true, isDisable : false},
    { Id: "InteractiveTypeRadio", isVisible: true, isDisable : false},
    { Id: "templateType", isVisible: true, isDisable : true},
    { Id: "createNewOrExisting", isVisible: true, isDisable : true}
 ];
const templateMap = new Map();
templateMap.set("createUI", createUI);
templateMap.set("editUI", editUI);
templateMap.set("createBI", createBI);
templateMap.set("createBINew", createBINew);
templateMap.set("editBI", editBI);

templateArray = templateMap.get(editMode)
return templateArray;

}