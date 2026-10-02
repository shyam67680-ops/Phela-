<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AuraSound - Modern Music Player</title>
    <!-- Tailwind CSS for sleek UI styling -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons for aesthetic icons -->
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

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        ::-webkit-scrollbar-track {
            background: rgba(15, 23, 42, 0.6);
        }
        ::-webkit-scrollbar-thumb {
            background: rgba(99, 102, 241, 0.4);
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: rgba(99, 102, 241, 0.8);
        }

        /* Custom Range Slider */
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

        /* Ambient Glow & Blur Effects */
        .glow-effect {
            box-shadow: 0 0 25px -5px rgba(99, 102, 241, 0.3);
        }
        .album-spin {
            animation: spin 20s linear infinite;
        }
        .album-spin-paused {
            animation-play-state: paused;
        }
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body class="h-screen flex flex-col antialiased selection:bg-indigo-500 selection:text-white">

    <div class="flex-1 flex overflow-hidden">

        <!-- Mobile Menu Backdrop -->
        <div id="mobile-backdrop" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-30 hidden md:hidden"></div>

        <!-- Sidebar Navigation -->
        <aside id="sidebar" class="fixed md:static inset-y-0 left-0 w-64 bg-slate-900/90 backdrop-blur-xl border-r border-slate-800/80 z-40 flex flex-col transform -translate-x-full md:translate-x-0 transition-transform duration-300 ease-in-out">
            <!-- Brand Header -->
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

            <!-- Navigation Links -->
            <nav class="px-4 space-y-1">
                <a href="#" class="flex items-center gap-3.5 px-4 py-3 rounded-xl bg-indigo-600/20 text-indigo-400 font-medium border border-indigo-500/20 transition-all">
                    <i data-lucide="home" class="w-5 h-5"></i> Discover
                </a>
                <a href="#" class="flex items-center gap-3.5 px-4 py-3 rounded-xl text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all">
                    <i data-lucide="compass" class="w-5 h-5"></i> Browse
                </a>
                <a href="#" class="flex items-center gap-3.5 px-4 py-3 rounded-xl text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all">
                    <i data-lucide="radio" class="w-5 h-5"></i> Radio
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

            <!-- Equalizer Mini Preview / Visualizer Card -->
            <div class="mt-auto p-4 m-4 rounded-2xl bg-gradient-to-b from-slate-800/80 to-slate-900/90 border border-slate-700/50 text-center">
                <p class="text-xs text-slate-400 mb-2 font-medium">Real-time Audio Visualizer</p>
                <canvas id="sidebar-visualizer" class="w-full h-12 rounded-lg bg-slate-950/60"></canvas>
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="flex-1 flex flex-col min-w-0 bg-slate-950/80 overflow-y-auto">
            <!-- Top Navbar -->
            <header class="sticky top-0 z-20 bg-slate-950/70 backdrop-blur-md border-b border-slate-800/60 px-6 py-4 flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 flex-1 max-w-md">
                    <button id="open-mobile-menu" class="md:hidden text-slate-400 hover:text-white p-1">
                        <i data-lucide="menu" class="w-6 h-6"></i>
                    </button>
                    <!-- Search Input -->
                    <div class="relative w-full">
                        <i data-lucide="search" class="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"></i>
                        <input type="text" id="search-input" placeholder="Search songs, artists, or genres..." class="w-full pl-10 pr-4 py-2 bg-slate-900/80 border border-slate-800 rounded-full text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-indigo-500/80 focus:ring-1 focus:ring-indigo-500/80 transition-all">
                    </div>
                </div>

                <!-- User Profile / Controls -->
                <div class="flex items-center gap-4">
                    <button id="theme-toggle" title="Toggle Visualizer Style" class="p-2 rounded-full bg-slate-900 border border-slate-800 text-slate-400 hover:text-indigo-400 transition-all">
                        <i data-lucide="sparkles" class="w-5 h-5"></i>
                    </button>
                    <div class="flex items-center gap-3 pl-2 border-l border-slate-800">
                        <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80" alt="Profile" class="w-8 h-8 rounded-full ring-2 ring-indigo-500/40 object-cover">
                        <span class="text-sm font-medium text-slate-300 hidden sm:inline">Alex Rivers</span>
                    </div>
                </div>
            </header>

            <!-- Main Content Container -->
            <div class="p-6 md:p-8 space-y-8">
                <!-- Hero Featured Track Banner -->
                <div id="hero-banner" class="relative rounded-3xl overflow-hidden p-6 md:p-8 border border-slate-800 bg-gradient-to-r from-indigo-950 via-slate-900 to-slate-950 flex flex-col md:flex-row items-center gap-6 shadow-2xl">
                    <div class="absolute inset-0 opacity-20 bg-[radial-gradient(#6366f1_1px,transparent_1px)] [background-size:16px_16px] pointer-events-none"></div>
                    
                    <div class="relative group">
                        <img id="hero-cover" src="" alt="Album Art" class="w-44 h-44 md:w-52 md:h-52 rounded-2xl object-cover shadow-2xl transition-transform duration-300 group-hover:scale-105">
                        <button id="hero-play-btn" class="absolute inset-0 m-auto w-14 h-14 bg-indigo-600/90 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all transform scale-75 group-hover:scale-100 shadow-xl backdrop-blur-sm">
                            <i data-lucide="play" class="w-7 h-7 fill-white ml-1"></i>
                        </button>
                    </div>

                    <div class="flex-1 text-center md:text-left z-10">
                        <span class="px-3 py-1 rounded-full text-xs font-semibold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 uppercase tracking-widest">Featured Track</span>
                        <h1 id="hero-title" class="text-2xl md:text-4xl font-bold text-white mt-3 mb-1">Select a Track</h1>
                        <p id="hero-artist" class="text-slate-400 text-lg font-medium mb-4">Artist Name</p>
                        
                        <!-- Visualizer Banner Overlay Canvas -->
                        <div class="w-full h-16 rounded-xl bg-slate-950/40 border border-slate-800/60 overflow-hidden relative mb-4">
                            <canvas id="hero-visualizer" class="w-full h-full"></canvas>
                        </div>

                        <div class="flex flex-wrap items-center justify-center md:justify-start gap-4">
                            <button id="hero-action-play" class="px-6 py-2.5 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 hover:from-indigo-600 hover:to-purple-700 text-white font-medium shadow-lg shadow-indigo-500/25 flex items-center gap-2 transition-all active:scale-95">
                                <i data-lucide="play" class="w-4 h-4 fill-white"></i> Play Now
                            </button>
                            <button id="hero-fav-btn" class="px-4 py-2.5 rounded-full bg-slate-800/80 hover:bg-slate-700 text-slate-300 font-medium border border-slate-700/60 flex items-center gap-2 transition-all">
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

                    <!-- Playlist Table / Grid -->
                    <div class="bg-slate-900/40 border border-slate-800/80 rounded-2xl overflow-hidden backdrop-blur-md">
                        <div class="grid grid-cols-12 px-6 py-3 border-b border-slate-800/80 text-xs font-semibold text-slate-400 uppercase tracking-wider hidden sm:grid">
                            <div class="col-span-1">#</div>
                            <div class="col-span-6">Title & Artist</div>
                            <div class="col-span-3">Genre</div>
                            <div class="col-span-2 text-right">Duration</div>
                        </div>

                        <div id="track-list" class="divide-y divide-slate-800/40">
                            <!-- Track Rows Generated Dynamically -->
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Bottom Persistent Audio Player Bar -->
    <footer class="bg-slate-900/95 border-t border-slate-800/80 px-4 md:px-8 py-3 z-30 backdrop-blur-xl">
        <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
            
            <!-- Track Meta Info (Left) -->
            <div class="flex items-center gap-4 w-full md:w-1/4">
                <div class="relative group flex-shrink-0">
                    <img id="player-thumb" src="https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=120&auto=format&fit=crop&q=80" alt="Track Thumbnail" class="w-14 h-14 rounded-xl object-cover border border-slate-700/60 shadow-md">
                    <div class="absolute inset-0 bg-black/30 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                        <i data-lucide="music" class="w-5 h-5 text-white"></i>
                    </div>
                </div>
                <div class="min-w-0 flex-1">
                    <h4 id="player-title" class="text-sm font-semibold text-white truncate">Select a Track</h4>
                    <p id="player-artist" class="text-xs text-slate-400 truncate">Artist Name</p>
                </div>
                <button id="player-fav-btn" class="text-slate-400 hover:text-rose-500 transition-colors p-1">
                    <i data-lucide="heart" class="w-5 h-5"></i>
                </button>
            </div>

            <!-- Player Controls & Seekbar (Center) -->
            <div class="flex flex-col items-center gap-2 w-full md:w-2/4">
                <!-- Control Buttons -->
                <div class="flex items-center gap-6">
                    <button id="shuffle-btn" class="text-slate-400 hover:text-indigo-400 transition-colors p-1" title="Shuffle">
                        <i data-lucide="shuffle" class="w-4 h-4"></i>
                    </button>
                    <button id="prev-btn" class="text-slate-300 hover:text-white transition-colors p-1" title="Previous">
                        <i data-lucide="skip-back" class="w-5 h-5 fill-current"></i>
                    </button>
                    <button id="play-btn" class="w-10 h-10 rounded-full bg-indigo-600 hover:bg-indigo-500 text-white flex items-center justify-center shadow-lg shadow-indigo-600/40 transition-all active:scale-95" title="Play/Pause">
                        <i data-lucide="play" class="w-5 h-5 fill-white ml-0.5"></i>
                    </button>
                    <button id="next-btn" class="text-slate-300 hover:text-white transition-colors p-1" title="Next">
                        <i data-lucide="skip-forward" class="w-5 h-5 fill-current"></i>
                    </button>
                    <button id="repeat-btn" class="text-slate-400 hover:text-indigo-400 transition-colors p-1" title="Repeat">
                        <i data-lucide="repeat" class="w-4 h-4"></i>
                    </button>
                </div>

                <!-- Progress Bar & Timers -->
                <div class="flex items-center gap-3 w-full max-w-md">
                    <span id="current-time" class="text-xs font-mono text-slate-400 w-10 text-right">0:00</span>
                    <input type="range" id="seek-bar" min="0" max="100" value="0" class="w-full cursor-pointer">
                    <span id="duration-time" class="text-xs font-mono text-slate-400 w-10">0:00</span>
                </div>
            </div>

            <!-- Volume & Extra Controls (Right) -->
            <div class="flex items-center justify-end gap-3 w-full md:w-1/4">
                <button id="mute-btn" class="text-slate-400 hover:text-slate-200 transition-colors">
                    <i data-lucide="volume-2" class="w-5 h-5"></i>
                </button>
                <input type="range" id="volume-bar" min="0" max="1" step="0.01" value="0.8" class="w-24 cursor-pointer">
            </div>
        </div>
    </footer>

    <script>
        // Audio Tracks Database with Generated Synthetic Audio Blobs (Self-contained)
        const trackList = [
            {
                id: 1,
                title: "Cybernetic Waves",
                artist: "Neon Pulse",
                genre: "Synthwave",
                duration: 180,
                durationStr: "3:00",
                cover: "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=400&auto=format&fit=crop&q=80",
                freq: 220, // Synthesizer base tone
                isFavorite: false
            },
            {
                id: 2,
                title: "Midnight Chill Out",
                artist: "Solaris",
                genre: "Lo-Fi Beats",
                duration: 210,
                durationStr: "3:30",
                cover: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&auto=format&fit=crop&q=80",
                freq: 174,
                isFavorite: true
            },
            {
                id: 3,
                title: "Electric Horizon",
                artist: "Aetheria",
                genre: "Ambient House",
                duration: 195,
                durationStr: "3:15",
                cover: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&auto=format&fit=crop&q=80",
                freq: 261,
                isFavorite: false
            },
            {
                id: 4,
                title: "Astral Echoes",
                artist: "Cosmic Mind",
                genre: "Chillstep",
                duration: 240,
                durationStr: "4:00",
                cover: "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&auto=format&fit=crop&q=80",
                freq: 196,
                isFavorite: false
            },
            {
                id: 5,
                title: "Velvet Groove",
                artist: "Urban Soul",
                genre: "Deep House",
                duration: 165,
                durationStr: "2:45",
                cover: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&auto=format&fit=crop&q=80",
                freq: 329,
                isFavorite: true
            }
        ];

        // Player State
        let currentTrackIndex = 0;
        let isPlaying = false;
        let isShuffle = false;
        let isRepeat = false;
        let activeFilter = 'all'; // 'all' or 'favorites'
        let visualizerTheme = 0; // 0: Bars, 1: Waveform

        // Web Audio API Synth Generator (Generates melody stream without needing external audio files)
        let audioCtx, oscillator, gainNode, analyser;
        let isAudioSetup = false;
        let audioTimer = null;
        let currentTimeSec = 0;

        function initWebAudio() {
            if (isAudioSetup) return;
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            audioCtx = new AudioContext();
            
            analyser = audioCtx.createAnalyser();
            analyser.fftSize = 64;

            gainNode = audioCtx.createGain();
            gainNode.gain.value = parseFloat(docu
