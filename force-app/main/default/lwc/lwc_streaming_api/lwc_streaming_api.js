/**
 * @author Shriram M

 * @desc This JS Provide functionality to create streaming api connections.
*/
import { LightningElement,api } from 'lwc';
import getSessionId from '@salesforce/apex/ChatController.getSessionId';
import { loadScript } from 'lightning/platformResourceLoader';
import cometdStaticResource from '@salesforce/resourceUrl/cometd';
import EngageCliq from '@salesforce/resourceUrl/engagecliq';

export default class Lwc_streaming_api extends LightningElement {
    //Channle Name
    @api channel;

    //Override the version of api to use cometd. By default it will use 45.
    @api apiVersion = '45.0';

    //If true then user can see console logs with data.
    @api debug = false;

    cometd;
    subscription;

    connectedCallback(){
        console.log('Streaming API - Component Loaded : ');
        this.loadCometdScript();
    }

    /**
     * @author Shriram M

     * @desc Loads the cometd static resource.
    */
    loadCometdScript(){
        if( !this.subscription ){
            Promise.all([
                loadScript(this, EngageCliq+'/octet-stream/cometd/cometd.js')
            ])
            .then(() => {
                console.log('in then : ');
                this.loadSessionId();
            })
            .catch(error => {
                console.log('in error : ');
                let message = error.message || error.body.message;
                console.log('error: '+message);
                this.fireErrorEvent(message);
            });
        }
        else{
            this.fireErrorEvent('Subscription already exists.');
            console.log('(LWC Streaming API) Error: Subscription already exists.');
        }
    }

    /**
     * @author Shriram M

     * @desc Loads the session id and create a connection with cometd.
    */
    loadSessionId(){
        getSessionId()
        .then(sessionId => {
            //this.consoleLog('(LWC Streaming API) Session ID: '+sessionId);
            console.log('(LWC Streaming API) Session ID: '+sessionId);

            //Initiating Cometd
            this.cometd = new window.org.cometd.CometD();

            //Configuring Cometd
            this.cometd.configure({
                url: window.location.protocol + '//' + window.location.hostname + '/cometd/'+this.apiVersion+'/',
                requestHeaders: { Authorization: 'OAuth ' + sessionId},
                appendMessageTypeToURL : false
            });
            this.cometd.websocketEnabled = false;

            //Initiating Cometd Handshake
            this.cometd.handshake( (status) => {
                if (status.successful) {
                    console.log('(LWC Streaming API) Handshake Successful on : '+ this.channel );
                    console.log('(LWC Streaming API) Handshake Status: '+ JSON.stringify(status) );

                    //Subscribe to channel
                    this.subscription = this.cometd.subscribe( this.channel , (message) => {
                        console.log('(LWC Streaming API) Message: '+ JSON.stringify(message) );
                        this.fireMessageEvent(message);
                    });
                }
                else{
                    console.log('(LWC Streaming API) Error in Handshake: '+ JSON.stringify(status) );
                    this.fireErrorEvent(status);
                }
            });

        })
        .catch(error => {
            let message = error.message || error.body.message;
            this.fireErrorEvent('Error: '+ message);
        });
    }

    /**
     * @author Shriram M

     * @desc Fire the error event.
    */
    fireErrorEvent(logMsg){
        this.dispatchEvent(
            new CustomEvent('error', {
                detail: {error: logMsg}
            })
        );
    }

    /**
     * @author Shriram M

     * @desc Fire the Payload/Message event.
    */
    fireMessageEvent(payload){
        this.dispatchEvent(
            new CustomEvent('message', {
                detail: {payload: payload}
            })
        );
    }

    /**
     * @author Shriram M

     * @desc Destroy the connection with channel.
    */
    @api
    unsubscribe(){
        //Unsubscribing Cometd
		this.cometd.unsubscribe( this.subscription, {}, (unsubResult) => {

            if( unsubResult.successful ) {
                this.consoleLog('(LWC Streaming API) unsubscribed successfully.');

                //Disconnecting Cometd
                this.cometd.disconnect((disResult) => {
                    if(disResult.successful) {
                        this.consoleLog('(LWC Streaming API) disconnected.');
                    }
                    else{
                        this.consoleLog('(LWC Streaming API) disconnection unsuccessful.');
                    }
                });
            }
            else{
                this.consoleLog('(LWC Streaming API) unsubscription failed.');
            }
        });

        this.subscription = undefined;
    }

    /**
     * @author Shriram M

     * @desc Reinitialize the connection with channel.
    */
    @api
    subscribe(){
        this.loadCometdScript();
    }

    /**
     * @author Shriram M

     * @desc Return true is connection is not destroyed.
    */
    @api
    checkConnection(){
        if( this.subscription ){
            return true;
        }

        return false;
    }

    /**
     * @author Shriram M

     * @desc Print console logs if debug is turned on.
    */
    consoleLog(msg){
        if( this.debug ){
        }
    }
}