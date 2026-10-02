<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AuraSound - Modern Music Player</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Google Fonts Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f17;
            color: #f3f4f6;
            overflow-x: hidden;
        }

        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: rgba(15, 23, 42, 0.6); }
        ::-webkit-scrollbar-thumb { background: rgba(99, 102, 241, 0.4); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(99, 102, 241, 0.8); }

        input[type=range] {
            -webkit-appearance: none;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 9999px;
            height: 6px;
        }
        input[type=range]::-webkit-slider-thumb {
            -webkit-appearance: none;
            height: 14px;
            width: 14px;
            border-radius: 50%;
            background: #818cf8;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            box-shadow: 0 0 10px rgba(129, 140, 248, 0.5);
        }
        input[type=range]::-webkit-slider-thumb:hover {
            transform: scale(1.2);
            background: #6366f1;
        }
    </style>
</head>
<body class="h-screen flex flex-col antialiased selection:bg-indigo-500 selection:text-white">

    <!-- Hidden YouTube Player Container -->
    <div id="youtube-player" class="hidden"></div>

    <div class="flex-1 flex overflow-hidden">
        <!-- Mobile Menu Backdrop -->
        <div id="mobile-backdrop" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-30 hidden md:hidden"></div>

        <!-- Sidebar Navigation -->
        <aside id="sidebar" class="fixed md:static inset-y-0 left-0 w-64 bg-slate-900/90 backdrop-blur-xl border-r border-slate-800/80 z-40 flex flex-col transform -translate-x-full md:translate-x-0 transition-transform duration-300 ease-in-out">
            <div class="p-6 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 via-purple-600 to-pink-500 flex items-center justify-center shadow-lg shadow-indigo-500/30">
                        <i data-lucide="disc" class="w-6 h-6 text-white animate-pulse"></i>
                    </div>
                    <span class="font-bold text-xl tracking-tight bg-gradient-to-r from-white via-slate-200 to-indigo-300 bg-clip-text text-transparent">AuraSound</span>
                </div>
                <button id="close-mobile-menu" class="md:hidden text-slate-400 hover:text-white p-1">
                    <i data-lucide="x" class="w-6 h-6"></i>
                </button>
            </div>

            <nav class="px-4 space-y-1">
                <a href="#" class="flex items-center gap-3.5 px-4 py-3 rounded-xl bg-indigo-600/20 text-indigo-400 font-medium border border-indigo-500/20 transition-all">
                    <i data-lucide="home" class="w-5 h-5"></i> Discover
                </a>
            </nav>

            <div class="mt-8 px-4">
                <h3 class="px-4 text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Your Library</h3>
                <nav class="space-y-1">
                    <a href="#" id="filter-all" class="filter-btn active-filter flex items-center justify-between px-4 py-2.5 rounded-lg text-sm text-slate-300 hover:bg-slate-800/50 transition-all">
                        <span class="flex items-center gap-3"><i data-lucide="music" class="w-4 h-4 text-indigo-400"></i> All Tracks</span>
                        <span id="all-count" class="text-xs bg-slate-800 text-slate-400 px-2 py-0.5 rounded-full">0</span>
                    </a>
                    <a href="#" id="filter-favorites" class="filter-btn flex items-center justify-between px-4 py-2.5 rounded-lg text-sm text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all">
                        <span class="flex items-center gap-3"><i data-lucide="heart" class="w-4 h-4 text-rose-500"></i> Favorites</span>
                        <span id="fav-count" class="text-xs bg-slate-800 text-slate-400 px-2 py-0.5 rounded-full">0</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="flex-1 flex flex-col min-w-0 bg-slate-950/80 overflow-y-auto">
            <header class="sticky top-0 z-20 bg-slate-950/70 backdrop-blur-md border-b border-slate-800/60 px-6 py-4 flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 flex-1 max-w-md">
                    <button id="open-mobile-menu" class="md:hidden text-slate-400 hover:text-white p-1">
                        <i data-lucide="menu" class="w-6 h-6"></i>
                    </button>
                    <div class="relative w-full">
                        <i data-lucide="search" class="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"></i>
                        <input type="text" id="search-input" placeholder="Search songs, artists, or genres..." class="w-full pl-10 pr-4 py-2 bg-slate-900/80 border border-slate-800 rounded-full text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-indigo-500/80">
                    </div>
                </div>
            </header>

            <div class="p-6 md:p-8 space-y-8">
                <!-- Hero Featured Track Banner -->
                <div id="hero-banner" class="relative rounded-3xl overflow-hidden p-6 md:p-8 border border-slate-800 bg-gradient-to-r from-indigo-950 via-slate-900 to-slate-950 flex flex-col md:flex-row items-center gap-6 shadow-2xl">
                    <div class="relative group">
                        <img id="hero-cover" src="" alt="Album Art" class="w-44 h-44 md:w-52 md:h-52 rounded-2xl object-cover shadow-2xl transition-transform duration-300 group-hover:scale-105">
                        <button id="hero-play-btn" class="absolute inset-0 m-auto w-14 h-14 bg-indigo-600/90 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all transform scale-75 group-hover:scale-100 shadow-xl">
                            <i data-lucide="play" class="w-7 h-7 fill-white ml-1"></i>
                        </button>
                    </div>

                    <div class="flex-1 text-center md:text-left z-10">
                        <span class="px-3 py-1 rounded-full text-xs font-semibold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 uppercase tracking-widest">YouTube Audio</span>
                        <h1 id="hero-title" class="text-2xl md:text-4xl font-bold text-white mt-3 mb-1">Select a Track</h1>
                        <p id="hero-artist" class="text-slate-400 text-lg font-medium mb-4">Artist Name</p>
                        
                        <div class="flex flex-wrap items-center justify-center md:justify-start gap-4">
                            <button id="hero-action-play" class="px-6 py-2.5 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 text-white font-medium shadow-lg flex items-center gap-2">
                                <i data-lucide="play" class="w-4 h-4 fill-white"></i> Play Now
                            </button>
                            <button id="hero-fav-btn" class="px-4 py-2.5 rounded-full bg-slate-800/80 hover:bg-slate-700 text-slate-300 font-medium border border-slate-700/60 flex items-center gap-2">
                                <i data-lucide="heart" class="w-4 h-4"></i> Add to Favorite
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Track List Section -->
                <div class="space-y-4">
                    <div class="flex items-center justify-between">
                        <h2 class="text-xl font-bold text-white tracking-tight flex items-center gap-2">
                            <i data-lucide="list-music" class="w-5 h-5 text-indigo-400"></i> Playlist Tracks
                        </h2>
                        <span id="playlist-count-label" class="text-xs text-slate-400">0 Songs</span>
                    </div>

                    <div class="bg-slate-900/40 border border-slate-800/80 rounded-2xl overflow-hidden">
                        <div class="grid grid-cols-12 px-6 py-3 border-b border-slate-800/80 text-xs font-semibold text-slate-400 uppercase tracking-wider hidden sm:grid">
                            <div class="col-span-1">#</div>
                            <div class="col-span-6">Title & Artist</div>
                            <div class="col-span-3">Genre</div>
                            <div class="col-span-2 text-right">Duration</div>
                        </div>

                        <div id="track-list" class="divide-y divide-slate-800/40"></div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Bottom Audio Player Bar -->
    <footer class="bg-slate-900/95 border-t border-slate-800/80 px-4 md:px-8 py-3 z-30 backdrop-blur-xl">
        <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
            
            <div class="flex items-center gap-4 w-full md:w-1/4">
                <img id="player-thumb" src="" alt="Thumbnail" class="w-14 h-14 rounded-xl object-cover border border-slate-700/60">
                <div class="min-w-0 flex-1">
                    <h4 id="player-title" class="text-sm font-semibold text-white truncate">Select a Track</h4>
                    <p id="player-artist" class="text-xs text-slate-400 truncate">Artist Name</p>
                </div>
                <button id="player-fav-btn" class="text-slate-400 hover:text-rose-500 p-1">
                    <i data-lucide="heart" class="w-5 h-5"></i>
                </button>
            </div>

            <div class="flex flex-col items-center gap-2 w-full md:w-2/4">
                <div class="flex items-center gap-6">
                    <button id="prev-btn" class="text-slate-300 hover:text-white p-1"><i data-lucide="skip-back" class="w-5 h-5 fill-current"></i></button>
                    <button id="play-btn" class="w-10 h-10 rounded-full bg-indigo-600 hover:bg-indigo-500 text-white flex items-center justify-center shadow-lg"><i data-lucide="play" class="w-5 h-5 fill-white ml-0.5"></i></button>
                    <button id="next-btn" class="text-slate-300 hover:text-white p-1"><i data-lucide="skip-forward" class="w-5 h-5 fill-current"></i></button>
                </div>

                <div class="flex items-center gap-3 w-full max-w-md">
                    <span id="current-time" class="text-xs font-mono text-slate-400 w-10 text-right">0:00</span>
                    <input type="range" id="seek-bar" min="0" max="100" value="0" class="w-full cursor-pointer">
                    <span id="duration-time" class="text-xs font-mono text-slate-400 w-10">0:00</span>
                </div>
            </div>

            <div class="flex items-center justify-end gap-3 w-full md:w-1/4">
                <button id="mute-btn" class="text-slate-400 hover:text-slate-200"><i data-lucide="volume-2" class="w-5 h-5"></i></button>
                <input type="range" id="volume-bar" min="0" max="100" value="80" class="w-24 cursor-pointer">
            </div>
        </div>
    </footer>

    <!-- Load YouTube IFrame API -->
    <script src="https://www.youtube.com/iframe_api"></script>

    <script>
        // 1. YouTube Video IDs yahan add karein (v= ke baad wala code)
        const trackList = [
            {
                id: 1,
                title: "Starboy",
                artist: "The Weeknd",
                genre: "Pop / R&B",
                youtubeId: "34Na4j8AVgA", // YouTube Video ID
                cover: "https://img.youtube.com/vi/34Na4j8AVgA/hqdefault.jpg",
                isFavorite: false
            },
            {
                id: 2,
                title: "Blinding Lights",
                artist: "The Weeknd",
                genre: "Synthwave",
                youtubeId: "4NRXx6U8ABQ",
                cover: "https://img.youtube.com/vi/4NRXx6U8ABQ/hqdefault.jpg",
                isFavorite: true
            },
            {
                id: 3,
                title: "Shape of You",
                artist: "Ed Sheeran",
                genre: "Pop",
                youtubeId: "JGwWNGJdvx8",
                cover: "https://img.youtube.com/vi/JGwWNGJdvx8/hqdefault.jpg",
                isFavorite: false
            }
        ];

        let ytPlayer;
        let currentTrackIndex = 0;
        let isPlaying = false;
        let activeFilter = 'all';
        let updateTimer;

        // YouTube Player Ready Event
        function onYouTubeIframeAPIReady() {
            ytPlayer = new YT.Player('youtube-player', {
                height: '0',
                width: '0',
                videoId: trackList[0].youtubeId,
                playerVars: { 'autoplay': 0, 'controls': 0 },
                events: {
                    'onReady': onPlayerReady,
                    'onStateChange': onPlayerStateChange
                }
            });
        }

        function onPlayerReady() {
            loadTrack(0);
        }

        function onPlayerStateChange(event) {
            if (event.data === YT.PlayerState.ENDED) {
                nextTrack();
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            lucide.createIcons();
            renderPlaylist();

            document.getElementById('play-btn').addEventListener('click', togglePlay);
            document.getElementById('hero-action-play').addEventListener('click', togglePlay);
            document.getElementById('hero-play-btn').addEventListener('click', togglePlay);
            document.getElementById('prev-btn').addEventListener('click', prevTrack);
            document.getElementById('next-btn').addEventListener('click', nextTrack);

            // Volume Control
            document.getElementById('volume-bar').addEventListener('input', (e) => {
                if (ytPlayer && ytPlayer.setVolume) {
                    ytPlayer.setVolume(e.target.value);
                }
            });

            // Seek Bar Control
            document.getElementById('seek-bar').addEventListener('input', (e) => {
                if (ytPlayer && ytPlayer.getDuration) {
                    const seekToSec = (e.target.value / 100) * ytPlayer.getDuration();
                    ytPlayer.seekTo(seekToSec, true);
                }
            });

            // Filters & Favorites
            document.getElementById('filter-all').addEventListener('click', () => setFilter('all'));
            document.getElementById('filter-favorites').addEventListener('click', () => setFilter('favorites'));
            document.getElementById('player-fav-btn').addEventListener('click', toggleCurrentFavorite);
            document.getElementById('hero-fav-btn').addEventListener('click', toggleCurrentFavorite);
        });

        function loadTrack(index) {
            currentTrackIndex = index;
            const track = trackList[currentTrackIndex];

            document.getElementById('hero-title').textContent = track.title;
            document.getElementById('hero-artist').textContent = track.artist;
            document.getElementById('hero-cover').src = track.cover;

            document.getElementById('player-title').textContent = track.title;
            document.getElementById('player-artist').textContent = track.artist;
            document.getElementById('player-thumb').src = track.cover;

            if (ytPlayer && ytPlayer.loadVideoById) {
                ytPlayer.loadVideoById(track.youtubeId);
                if (!isPlaying) ytPlayer.pauseVideo();
            }

            updateFavButtonsUI();
            highlightActiveTrackRow();
        }

        function togglePlay() {
            if (!ytPlayer) return;

            isPlaying = !isPlaying;
            const playIcon = '<i data-lucide="play" class="w-5 h-5 fill-white ml-0.5"></i>';
            const pauseIcon = '<i data-lucide="pause" class="w-5 h-5 fill-white"></i>';

            document.getElementById('play-btn').innerHTML = isPlaying ? pauseIcon : playIcon;
            document.getElementById('hero-action-play').innerHTML = isPlaying ? pauseIcon + ' Pause' : playIcon + ' Play Now';
            lucide.createIcons();

            if (isPlaying) {
                ytPlayer.playVideo();
                startProgressLoop();
            } else {
                ytPlayer.pauseVideo();
                clearInterval(updateTimer);
            }
            highlightActiveTrackRow();
        }

        function startProgressLoop() {
            clearInterval(updateTimer);
            updateTimer = setInterval(() => {
                if (ytPlayer && ytPlayer.getCurrentTime) {
                    const current = ytPlayer.getCurrentTime();
                    const duration = ytPlayer.getDuration();
                    if (duration > 0) {
                        document.getElementById('seek-bar').value = (current / duration) * 100;
                        document.getElementById('current-time').textContent = formatTime(current);
                        document.getElementById('duration-time').textContent = formatTime(duration);
                    }
                }
            }, 1000);
        }

        function nextTrack() {
            currentTrackIndex = (currentTrackIndex + 1) % trackList.length;
            loadTrack(currentTrackIndex);
            if (isPlaying) ytPlayer.playVideo();
        }

        function prevTrack() {
            currentTrackIndex = (currentTrackIndex - 1 + trackList.length) % trackList.length;
            loadTrack(currentTrackIndex);
            if (isPlaying) ytPlayer.playVideo();
        }

        function formatTime(sec) {
            const m = Math.floor(sec / 60);
            const s = Math.floor(sec % 60);
            return `${m}:${s < 10 ? '0' : ''}${s}`;
        }

        function renderPlaylist() {
            const container = document.getElementById('track-list');
            container.innerHTML = '';

            const filtered = trackList.filter(t => activeFilter === 'all' || t.isFavorite);

            document.getElementById('all-count').textContent = trackList.length;
            document.getElementById('fav-count').textContent = trackList.filter(t => t.isFavorite).length;
            document.getElementById('playlist-count-label').textContent = `${filtered.length} Songs`;

            filtered.forEach((track, idx) => {
                const isCurrent = track.id === trackList[currentTrackIndex].id;
                const row = document.createElement('div');
                row.className = `grid grid-cols-12 px-6 py-3.5 items-center hover:bg-slate-800/40 cursor-pointer ${isCurrent ? 'bg-indigo-950/30 border-l-4 border-indigo-500' : ''}`;
                
                row.innerHTML = `
                    <div class="col-span-1 text-sm font-mono text-slate-500">${idx + 1}</div>
                    <div class="col-span-11 sm:col-span-6 flex items-center gap-3 min-w-0">
                        <img src="${track.cover}" class="w-10 h-10 rounded-lg object-cover">
                        <div class="min-w-0">
                            <h5 class="text-sm font-medium ${isCurrent ? 
