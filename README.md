# Coolie - Furniture Ecommerce Application

A modern, full-stack furniture ecommerce application built with React, Node.js, and Supabase.

## 🚀 Features

### Frontend
- **Modern React Application** with TypeScript
- **Responsive Design** optimized for all devices
- **Product Catalog** with filtering and search
- **Shopping Cart** with persistent storage
- **Category Navigation** and product browsing
- **Product Detail Pages** with image galleries
- **Admin Dashboard** for product management
- **User Authentication** with Supabase Auth

### Backend
- **RESTful API** built with Node.js and Express
- **Supabase Database** integration
- **Product Management** CRUD operations
- **Order Processing** system
- **Category Management**
- **User Authentication** and authorization
- **File Upload** support for product images

### Database
- **PostgreSQL** database via Supabase
- **Row Level Security** (RLS) enabled
- **Optimized Schema** for ecommerce operations
- **Sample Data** included for testing

## 🛠️ Tech Stack

- **Frontend**: React 18, TypeScript, Tailwind CSS, Vite
- **Backend**: Node.js, Express, Supabase
- **Database**: PostgreSQL (via Supabase)
- **State Management**: Zustand
- **Routing**: React Router
- **UI Components**: Custom components with Lucide React icons
- **Containerization**: Docker & Docker Compose

## 📋 Prerequisites

- Node.js 18 or higher
- Docker and Docker Compose
- Supabase account

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd coolie-furniture-ecommerce
```

### 2. Set Up Supabase

1. Create a new project on [Supabase](https://supabase.com)
2. Run the migration file in the Supabase SQL editor:
   ```sql
   -- Copy and paste the contents from supabase/migrations/create_furniture_schema.sql
   ```
3. Get your project credentials from the API settings

### 3. Environment Setup

Create `.env` files in both root and backend directories:

**Root `.env`:**
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Backend `.env`:**
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
PORT=3001
NODE_ENV=development
```

### 4. Run with Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up -d
```

### 5. Manual Setup (Alternative)

If you prefer to run without Docker:

**Install Frontend Dependencies:**
```bash
npm install
```

**Install Backend Dependencies:**
```bash
cd backend
npm install
```

**Start Frontend (from root):**
```bash
npm run dev
```

**Start Backend:**
```bash
cd backend
npm run dev
```

## 📁 Project Structure

```
coolie-furniture-ecommerce/
├── src/                          # Frontend source code
│   ├── components/              # React components
│   │   ├── layout/             # Layout components (Header, Footer)
│   │   ├── ui/                 # UI components (ProductCard, etc.)
│   │   └── cart/               # Shopping cart components
│   ├── hooks/                   # Custom React hooks
│   ├── pages/                   # Page components
│   ├── store/                   # Zustand store
│   └── lib/                     # Utility libraries
├── backend/                     # Backend API
│   ├── routes/                 # API routes
│   ├── package.json
│   └── server.js               # Express server
├── supabase/
│   └── migrations/             # Database migrations
├── docker-compose.yml           # Docker services configuration
├── Dockerfile.frontend         # Frontend container
└── README.md
```

## 🗄️ Database Schema

### Tables

- **categories**: Product categories (Living Room, Bedroom, etc.)
- **products**: Product catalog with images, pricing, and specifications
- **orders**: Customer orders
- **order_items**: Individual items within orders

### Security

- Row Level Security (RLS) enabled on all tables
- Public read access for products and categories
- Authenticated user access for orders
- Admin policies for product management

## 🌐 API Endpoints

### Products
- `GET /api/products` - Get all products with filtering
- `GET /api/products/:id` - Get single product
- `POST /api/products` - Create new product (admin)
- `PUT /api/products/:id` - Update product (admin)
- `DELETE /api/products/:id` - Delete product (admin)

### Categories
- `GET /api/categories` - Get all categories
- `GET /api/categories/:id` - Get category with products
- `POST /api/categories` - Create category (admin)
- `PUT /api/categories/:id` - Update category (admin)
- `DELETE /api/categories/:id` - Delete category (admin)

### Orders
- `GET /api/orders` - Get user orders (authenticated)
- `POST /api/orders` - Create new order (authenticated)

## 🎨 Design Features

- **Modern UI** with clean, professional aesthetics
- **Responsive Design** for mobile, tablet, and desktop
- **Product Image Galleries** with zoom functionality
- **Smooth Animations** and hover effects
- **Intuitive Navigation** and filtering
- **Shopping Cart** with real-time updates
- **Toast Notifications** for user feedback

## 🔧 Development

### Frontend Development
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint
```

### Backend Development
```bash
cd backend

# Start development server with auto-reload
npm run dev

# Start production server
npm start
```

## 🚀 Deployment

The application is containerized and ready for deployment on any platform supporting Docker:

- **Frontend**: Built and served via Vite
- **Backend**: Node.js API server
- **Database**: Supabase (managed PostgreSQL)

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📧 Support

For questions or support, please create an issue in the repository or contact the development team.

---

**Coolie Furniture** - Transform your space with premium furniture designed for modern living.