import { useQuery } from "@tanstack/react-query";
import axios from "axios";

export const useOrders = () => {
  return useQuery({
    queryKey: ["orders"],
    queryFn: async () => {
      const { data } = await axios.get(
        "https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/orders"
      );

      return data;
    },
  });
};
