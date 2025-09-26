import { LightningElement, api, track, wire} from 'lwc';
import getData from "@salesforce/apex/customCadenceController.getData";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomCadence extends LightningElement {

@api objectApiName;
@api recordId;
@track currenObjectName;
@track value = 'Email';
@track startD = '';
@track noCad = 0;
@track intCad = 0;
@track userVal ;
@track checkboxVal = false ;
@track valueRem = 'previousDay';
@track checkboxValRem = false;

connectedCallback() {
this.currenObjectName = this.objectApiName;
}

handleUser(event){
this.userVal = event.detail;
}

get options() {
return [
{ label: 'Email', value: 'Email' },
{ label: 'Call', value: 'Call' },
];
}

handleChange(event) {
this.value = event.detail.value;
}

startDate(event){
this.startD = event.detail.value;
}

cadChange(event){
this.noCad = event.detail.value;
}

intCadChange(event){
this.intCad = event.detail.value;
}

onChecboxChange(event){
this.checkboxVal = event.target.checked;
}

onChecboxChangeRem(event){
    this.checkboxValRem = event.target.checked;
    }

get optionsRem() {
return [
{ label: 'Previous Day of the Task', value: 'previousDay' },
{ label: 'Same Day of the Task', value: 'sameDay' },
];
}

handleChangeRem(event) {
this.valueRem = event.detail.value;
}

handleCancel(event){
window.location.reload();
}

handleSave(event){
getData({ 
recId : this.recordId, 
objectName : this.currenObjectName, 
type : this.value,
sDate : this.startD,
nCad :this.noCad ,
intervalCad : this.intCad,
cadOwner : this.userVal,
cboxVal : this.checkboxVal,
cboxRem : this.checkboxValRem,
remSet : this.valueRem
})
.then(result => {
const event = new ShowToastEvent({
title: 'Cadences are created',
message: 'Success',
variant: 'success'
});
this.dispatchEvent(event);
window.location.reload();

})
.catch(error => {
const event = new ShowToastEvent({
title : 'Error',
message : 'Error creating cadences. Please Contact System Admin',
variant : 'error' 
});
this.dispatchEvent(event);
window.location.reload();

});
}
}