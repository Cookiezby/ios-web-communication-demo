function hello() {
    console.log("hello");
}

let requestIdCounter = 0;
const pendingRequests = new Map();

function generateRequestId() {
    return `request_${requestIdCounter++}`;
}

function sendMessageToNative(detail) {
    return new Promise((resolve, reject) => {
        const requestId = generateRequestId();
        pendingRequests.set(requestId, resolve);
        window.handleNativeResponse = (response, requestId) => {
            const handler = pendingRequests.get(requestId);
            if (handler) {
                handler(response);
                pendingRequests.delete(requestId);
            }
        };
        // Add requestId to the detail object
        const messageWithRequestId = Object.assign(Object.assign({}, detail), { requestId });
        window.webkit.messageHandlers.bridge.postMessage(messageWithRequestId);
    });
}

async function updateTitleWithDataFromNative() {
    const data = await sendMessageToNative({ eventName: "getRandomTitle" });
    const element = document.querySelector(".center-text");
    element.textContent = data;
}
