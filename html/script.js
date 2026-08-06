const lobbyPanel = document.getElementById('lobby-panel');
const lobbyTimer = document.getElementById('lobby-timer');
const lobbyList = document.getElementById('lobby-list');
const lobbyCount = document.getElementById('lobby-count');
const joinBtn = document.getElementById('join-btn');
const joinedMsg = document.getElementById('joined-msg');

const invitePanel = document.getElementById('invite-panel');
const acceptBtn = document.getElementById('accept-btn');
const declineBtn = document.getElementById('decline-btn');

const spawnPanel = document.getElementById('spawn-panel');
const spawnTimer = document.getElementById('spawn-timer');
const mapWrapper = document.getElementById('map-wrapper');
const mapImage = document.getElementById('map-image');
const zoneCircle = document.getElementById('zone-circle');
const villaZone = document.getElementById('villa-zone');
const mapMarker = document.getElementById('map-marker');
const spawnStatus = document.getElementById('spawn-status');
const spawnLoading = document.getElementById('spawn-loading');
const confirmSpawnBtn = document.getElementById('confirm-spawn-btn');

const countdownOverlay = document.getElementById("countdown-overlay");
const countdownNumber = document.getElementById("countdown-number");

let currentMinPlayers = 1;
let currentOnlinePlayers = 0;
let spawnLocked = false;
let lobbyJoined = false;
let pendingSpawnPct = null;
let loadingTick = null;

function setSpawnStatus(text, isError) {
    if (!text) {
        spawnStatus.textContent = '';
        spawnStatus.classList.add('hidden');
        spawnStatus.classList.remove('error');
        return;
    }

    spawnStatus.textContent = text;
    spawnStatus.classList.remove('hidden');
    spawnStatus.classList.toggle('error', !!isError);
}

function startLoading() {
    const frames = ['Töltés.', 'Töltés..', 'Töltés...'];
    let idx = 0;
    spawnLoading.textContent = frames[idx];
    spawnLoading.classList.remove('hidden');
    clearInterval(loadingTick);
    loadingTick = setInterval(() => {
        idx = (idx + 1) % frames.length;
        spawnLoading.textContent = frames[idx];
    }, 350);
}

function stopLoading() {
    clearInterval(loadingTick);
    loadingTick = null;
    spawnLoading.classList.add('hidden');
}

function post(name, data) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {})
    }).then(r => r.json()).catch(() => ({}));
}

window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case "showCountdown":

            countdownOverlay.classList.remove("hidden");

            countdownNumber.classList.remove("countdown-fight");

            countdownNumber.textContent = data.value;

            countdownNumber.style.animation = "none";

            countdownNumber.offsetHeight;

            countdownNumber.style.animation = "";

            break;

        case "updateCountdown":

            countdownNumber.classList.remove("countdown-fight");

            countdownNumber.textContent = data.value;

            countdownNumber.style.animation = "none";

            countdownNumber.offsetHeight;

            countdownNumber.style.animation = "";

            break;

        case "fight":

            countdownNumber.textContent = "HARCOLJ!";

            countdownNumber.classList.add("countdown-fight");

            countdownNumber.style.animation = "none";

            countdownNumber.offsetHeight;

            countdownNumber.style.animation = "";

            break;

        case "hideCountdown":

            countdownOverlay.classList.add("hidden");

            break;
        case "showHUD":

            document.getElementById("hg-hud").classList.remove("hidden");
            break;

        case "hideHUD":

            document.getElementById("hg-hud").classList.add("hidden");
            break;

        case "updateHUD":

            document.getElementById("hg-alive").textContent = data.alive;
            document.getElementById("hg-kills").textContent = data.kills;
            break;

        case 'showInvite':

            invitePanel.classList.remove('hidden');
            lobbyPanel.classList.add('hidden');

            break;

        case 'hideInvite':

            invitePanel.classList.add('hidden');

            break;
        case 'spawnError':

            setSpawnStatus(data.text, true);

            break;
        case 'showLobby':

            currentMinPlayers = data.minPlayers;
            currentOnlinePlayers = data.onlinePlayers || 0;

            lobbyJoined = !!data.joined;

            lobbyPanel.classList.remove('hidden');

            renderLobbyPlayers(data.players || [], data.minPlayers);

            lobbyTimer.textContent = data.timeLeft + "s";
            syncLobbyJoinedState();

            break;

        case 'hideLobby':
            lobbyPanel.classList.add('hidden');
            break;

        case 'lobbyTimer':
            lobbyTimer.textContent = data.timeLeft + 's';
            break;

        case 'updateLobby':

            currentOnlinePlayers = data.onlinePlayers;

            renderLobbyPlayers(data.players, data.minPlayers);

            lobbyTimer.textContent = data.timeLeft + "s";
            lobbyCount.textContent =
                `${data.joinedPlayers} / ${data.onlinePlayers}`;

            break;

        case 'showSpawnMap':

            spawnPanel.classList.remove('hidden');

            stopLoading();
            spawnLocked = false;
            pendingSpawnPct = null;

            mapMarker.classList.add('hidden');
            confirmSpawnBtn.disabled = true;

            setSpawnStatus('', false);

            mapImage.src = data.mapImage;

            if (data.villa) {

                positionRect(

                    villaZone,
                    data.villa.x,
                    data.villa.y,
                    data.villa.w,
                    data.villa.h,
                    false

                );

            }

            let timeLeft = data.timeLeft;

            spawnTimer.textContent = timeLeft + "s";

            if (window.spawnTimerInterval) {
                clearInterval(window.spawnTimerInterval);
            }

            window.spawnTimerInterval = setInterval(() => {

                timeLeft--;

                if (timeLeft < 0) {

                    clearInterval(window.spawnTimerInterval);

                    return;

                }

                spawnTimer.textContent = timeLeft + "s";

            }, 1000);

            break;

        case 'hideSpawnMap':
            spawnPanel.classList.add('hidden');
            pendingSpawnPct = null;
            confirmSpawnBtn.disabled = true;
            stopLoading();
            setSpawnStatus('', false);
            if (window.spawnTimerInterval) {
                clearInterval(window.spawnTimerInterval);
            }
            break;

        case 'showSpawnLoading':
            spawnPanel.classList.remove('hidden');
            startLoading();
            setSpawnStatus(data.text || 'Töltés.', false);
            break;

        case 'hideSpawnLoading':
            stopLoading();
            break;

        case 'spawnMapTimer':
            spawnTimer.textContent = data.timeLeft + 's';
            break;
    }
});

function renderLobbyPlayers(players, minPlayers) {
    lobbyList.innerHTML = '';
    players.forEach(p => {
        const li = document.createElement('li');
        li.textContent = p.name;
        lobbyList.appendChild(li);
    });
    lobbyCount.textContent = `${players.length} / ${currentOnlinePlayers || players.length}`;
}

function syncLobbyJoinedState() {
    if (lobbyJoined) {
        joinBtn.classList.add('hidden');
        joinedMsg.classList.remove('hidden');
    } else {
        joinBtn.classList.remove('hidden');
        joinedMsg.classList.add('hidden');
    }
}

function positionRect(el, xPct, yPct, wPct, hPct, isCircle) {
    el.style.left = xPct + '%';
    el.style.top = yPct + '%';
    el.style.width = wPct + '%';
    el.style.height = hPct + '%';
    if (isCircle) {
        el.style.transform = 'translate(0,0)';
    }
}

joinBtn.addEventListener('click', () => {
    post('joinEvent', {}).then(res => {

        if (res && res.ok) {

            lobbyJoined = true;

            syncLobbyJoinedState();
        }
    });
});
mapWrapper.addEventListener('click', (e) => {
    if (spawnLocked) return;
    const rect = mapWrapper.getBoundingClientRect();
    const xPct = ((e.clientX - rect.left) / rect.width) * 100;
    const yPct = ((e.clientY - rect.top) / rect.height) * 100;

    pendingSpawnPct = { x: xPct, y: yPct };
    mapMarker.style.left = xPct + '%';
    mapMarker.style.top = yPct + '%';
    mapMarker.classList.remove('hidden');

    post('chooseSpawn', { x: xPct, y: yPct }).then(res => {
        if (res && res.ok) {
            setSpawnStatus('Kijelölve. Nyomd meg az UGRÁS gombot.', false);
            confirmSpawnBtn.disabled = false;
        } else {
            setSpawnStatus((res && res.reason) ? res.reason : 'Érvénytelen pont, válassz máshol!', true);
            mapMarker.classList.add('hidden');
            pendingSpawnPct = null;
            confirmSpawnBtn.disabled = true;
        }
    });
});

confirmSpawnBtn.addEventListener('click', () => {
    if (!pendingSpawnPct || spawnLocked) return;

    post('confirmSpawn', pendingSpawnPct).then(res => {
        if (res && res.ok) {
            spawnLocked = true;
            setSpawnStatus('Ugrás megerősítve.', false);
            confirmSpawnBtn.disabled = true;
        } else {
            setSpawnStatus((res && res.reason) ? res.reason : 'Nem sikerült az ugrás, válassz új pontot!', true);
        }
    });
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        post('closeLobby', {});
        lobbyPanel.classList.add('hidden');
    }
});

acceptBtn.addEventListener('click', () => {

    invitePanel.classList.add('hidden');

    post('acceptInvite', {});

});

declineBtn.addEventListener('click', () => {

    invitePanel.classList.add('hidden');

    post('declineInvite', {});

});