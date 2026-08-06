const lobbyPanel = document.getElementById('lobby-panel');
const lobbyTimer = document.getElementById('lobby-timer');
const lobbyList = document.getElementById('lobby-list');
const lobbyCount = document.getElementById('lobby-count');
const joinBtn = document.getElementById('join-btn');
const joinedMsg = document.getElementById('joined-msg');

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
        case 'showLobby':
            currentMinPlayers = data.minPlayers;
            currentOnlinePlayers = data.onlinePlayers || currentOnlinePlayers;
            lobbyJoined = !!data.joined;
            lobbyPanel.classList.remove('hidden');
            renderLobbyPlayers(data.players, data.minPlayers);
            syncLobbyJoinedState();
            break;

        case 'hideLobby':
            lobbyPanel.classList.add('hidden');
            break;

        case 'lobbyTimer':
            lobbyTimer.textContent = data.timeLeft + 's';
            break;

        case 'lobbyPlayers':
            currentOnlinePlayers = data.onlinePlayers || currentOnlinePlayers;
            renderLobbyPlayers(data.players, data.minPlayers);
            if (typeof data.joined === 'boolean') {
                lobbyJoined = data.joined;
            }
            syncLobbyJoinedState();
            break;

        case 'showSpawnMap':
            spawnLocked = false;
            pendingSpawnPct = null;
            spawnPanel.classList.remove('hidden');
            stopLoading();
            mapImage.src = data.mapImage;
            positionRect(zoneCircle, data.circle.x - data.circle.rx, data.circle.y - data.circle.ry, data.circle.rx * 2, data.circle.ry * 2, true);
            positionRect(villaZone, data.villa.x, data.villa.y, data.villa.w, data.villa.h, false);
            mapMarker.classList.add('hidden');
            setSpawnStatus('Kattints a térképre a landolási ponthoz. A piros terület TILTOTT.', false);
            confirmSpawnBtn.disabled = true;
            spawnTimer.textContent = data.timeLeft + 's';
            break;

        case 'hideSpawnMap':
            spawnPanel.classList.add('hidden');
            pendingSpawnPct = null;
            confirmSpawnBtn.disabled = true;
            stopLoading();
            setSpawnStatus('', false);
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